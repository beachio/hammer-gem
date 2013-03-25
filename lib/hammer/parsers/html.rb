class Hammer
  class HTMLParser < HammerParser
    
    @@cached_files = {}
    
    def to_html
      @text = @hammer_file.raw_text
      get_variables()
      includes()
      @text
    end

    def parse
      
      placeholders()
      get_variables()
      
      # TODO: Check whether we want to do this first
      path_tags()
      
      includes()
      get_variables()
      reload_tags()
      stylesheet_tags()
      javascript_tags()
      path_tags()
      output_variables()
      
      current_tags()
      
      return @text
    end
    
    def variables
      @variables ||= {}
    end
    
    def self.finished_extension
      'html'
    end

    private
    
    def placeholders
      replace(/<!-- @placeholder (\S*) -->/) do |tag, line_number|
        dimensions = tag.gsub("<!-- @placeholder ", "").gsub("-->", "").strip
        begin
          x = dimensions.split('x')[0]
          y = dimensions.split('x')[1]
          "<img src='http://placehold.it/#{x}x#{y}' width='#{x}px' height='#{y}px' />"
        rescue 
          tag
        end
      end
      
      replace(/<!-- @kitten (\S*) -->/) do |tag, line_number|
        dimensions = tag.gsub("<!-- @kitten ", "").gsub("-->", "").strip
        begin
          x = dimensions.split('x')[0]
          y = dimensions.split('x')[1]
          "<img src='http://placekitten.com/#{x}/#{y}' width='#{x}px' height='#{y}px' />"
        rescue 
          tag
        end
      end
    end
    
    def get_variables
      replace(/<!-- \$(.*?) -->/) do |tag, line_number|
        variable_declaration = tag.gsub("<!-- $", "").gsub("-->", "").strip.split(" ")
        variable_name = variable_declaration[0]
        variable_value = variable_declaration[1..-1].join(' ')
        # If there's a |, this is a getter with a default!
        # TODO: Update the regex to disallow | characters.
        if variable_value.start_with?("|") || variable_value == ""
          tag
        else
          self.variables[variable_name] = variable_value
          tag
        end
      end
    end
    
    def output_variables
      replace(/<!-- \$(.*?) -->/) do |tag, line_number|
        variable_declaration = tag.gsub("<!-- $", "").gsub(" -->", "").strip
        
        if variable_declaration.include? "|"
          variable_name = variable_declaration.split("|")[0].strip
          default = variable_declaration.split("|")[1..-1].join("|").strip rescue false
        else
          
          variable_name = variable_declaration.split(" ")[0]
        end
        if variable_declaration.include?(' ') && !(variable_declaration.include? "|")
          # Oh god it's a setter why are you still here
          self.variables[variable_name] = variable_declaration.split(" ")[1..-1].join(' ')
          ""
        elsif self.variables[variable_name] || default
          self.variables[variable_name] || default
        else
          raise "Variable <b>#{h variable_name}</b> wasn't set!"
        end
      end
    end
    
    def includes
      lines = []
      replace(/<!-- @include (.*?) -->/) do |tag, line_number|
        tags = tag.gsub("<!-- @include ", "").gsub("-->", "").strip.split(" ")
        tags.map do |tag|
          
          if (tag.start_with? "$")
            variable_value = variables[tag[1..-1]]
            
            if !variable_value
              raise "Includes: Can't include <b>#{h tag}</b> because <b>#{h tag}</b> isn't set."
            end
            
            tag = variable_value
          end
          
          file = find_file(tag, 'html')
          if file
            
            parser = @hammer_project.parser_for_hammer_file(file)
            parser.variables = self.variables
            
            begin
              parser.parse()
            rescue Hammer::Error => e
              e.hammer_file = file
              raise e
            end
            
            parser = @hammer_project.parser_for_hammer_file(file)
            parser.variables = self.variables
            self.variables = self.variables.merge(parser.variables)
            parser.to_html()
          else
            raise "Includes: File <b>#{h tag}</b> couldn't be found."
          end
        end.compact.join("\n")
      end
    end

    def reload_tags
      return if @hammer_project.production
      reloader_script = "
        <!-- Hammer reload -->
          <script>
            setInterval(function(){
              try {
                if(typeof ws != 'undefined' && ws.readyState == 1){return true;}
                ws = new WebSocket('ws://'+(location.host || 'localhost').split(':')[0]+':35353')
                ws.onopen = function(){ws.onclose = function(){document.location.reload()}}
                ws.onmessage = function(){
                  var links = document.getElementsByTagName('link'); 
                    for (var i = 0; i < links.length;i++) { 
                    var link = links[i]; 
                    if (link.rel === 'stylesheet' && !link.href.match(/typekit/)) { 
                      href = link.href.replace(/((&|\\?)hammer=)[^\&]+/,''); 
                      link.href = href + (href.indexOf('?')>=0?'&':'?') + 'hammer='+(new Date().valueOf());
                    }
                  }
                }
              }catch(e){}
            }, 1000)
          </script>
        <!-- /Hammer reload -->
      "
      @text = text.gsub(/<!-- @reload -->/, reloader_script)
    end
    
    def path_tags
      replace(/<!-- @path (.*?) -->/) do |tag, line_number|
        tag = tag.gsub("<!-- @path ", "").gsub("-->", "").strip
        
        file = find_file(tag)
        
        if !file
          raise "Path tags: <b>#{h tag}</b> couldn't be found."
        end
        
        path_to(file)
      end
    end

    def stylesheet_tags
      @included_stylesheets ||= []
      
      self.replace(/<!-- @stylesheet (.*?) -->/) do |tagged_path, line_number|
        results, tags, hammer_files, paths = [], [], [], [], []
        
        filenames = tagged_path.gsub("<!-- @stylesheet ", "").gsub("-->", "").strip.split(" ")
        
        filenames.each do |filename| 
          matching_files = find_files(filename, 'css')
          raise "Stylesheet tags: <b>#{h filename}</b> couldn't be found." if matching_files.empty?
          hammer_files += matching_files
        end
        
        hammer_files_to_tag = []
        hammer_files.each do |file|
          
          next if file.is_a_compiled_file
          next if File.basename(file.filename).start_with?("_")
          path = path_to(file)
          
          next if @included_stylesheets.include?(path) 
          @included_stylesheets << path
          hammer_files_to_tag << file
          paths << path
        end
        
        if production?
          file = add_file_from_files(hammer_files_to_tag, :css)
          "<link rel='stylesheet' href='#{path_to(file)}'>" if file
        else
          paths.map {|path| "<link rel='stylesheet' href='#{path}'>"}.compact.join("\n")
        end
      end
    end
    
    def add_file_from_files(files, format)
      return false if files == []
      # return false if files.collect(&:error) != []
      contents = []
      
      key = files.collect(&:to_s).join(':') + ":format"
      return @@cached_files[key] if @@cached_files[key]
      
      files.each do |file|
        contents << Hammer.parser_for_hammer_file(file).to_format(format)
      end
      contents = contents.join("\n\n\n\n")
      filename = Digest::MD5.hexdigest(contents)
      file = add_file("#{filename}.#{format}", contents)
      file.source_files = files
      
      @@cached_files[key] = file
      
      file
    end
    
    def path_to(hammer_file)
      them = Pathname.new(hammer_file.finished_filename)
      me =  Pathname.new(File.dirname(self.filename))
      path = them.relative_path_from(me)
      path
    end
    
    def javascript_tags
      @included_javascripts ||= []
      
      self.replace(/<!-- @javascript (.*?) -->/) do |tagged_path, line_number|
        results, tags, hammer_files, paths = [], [], [], [], []
        
        filenames = tagged_path.gsub("<!-- @javascript ", "").gsub("-->", "").strip.split(" ")
        
        filenames.each do |filename| 
          matching_files = find_files(filename, 'js')
          raise "Javascript tags: <b>#{h filename}</b> couldn't be found." if matching_files.empty?
          hammer_files += matching_files
        end
                
        hammer_files_to_tag = []
        hammer_files.each do |file|
          
          next if file.is_a_compiled_file
          next if File.basename(file.filename).start_with?("_")
          
          path = path_to(file)
          
          next if @included_javascripts.include?(path) 
          @included_javascripts << path
          hammer_files_to_tag << file
          paths << path
        end        
        if production?
          file = add_file_from_files(hammer_files_to_tag, :js)
          "<script src='#{path_to(file)}'></script>" if file
        else
          paths.map {|path| "<script src='#{path}'></script>"}.compact.join("\n")
        end
      end
    end
    
    def current_tags
      # If we don't have any links to the current page, let's get outta here real fast.
      # Otherwise, let's Amp it.
      filename = File.basename(@hammer_file.finished_filename)
      if !@hammer_file.finished_filename or !@text.match /href( )*\=( )*[" ']#{filename}["']/
        return 
      end
      @text = Amp.parse(@text, filename, 'current')
    end
  end
  register_parser_for_extensions HTMLParser, ['html']
  register_parser_as_default_for_extensions HTMLParser, ['html']
end