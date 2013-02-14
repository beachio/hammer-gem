class Hammer
  class HTMLParser < HammerParser
    
    def to_html
      @text = @hammer_file.raw_text
      
      includes()
      
      # Strip todos - they're for this file only
      # text.gsub(/<!-- @todo (.*) -->/, "")
      
      @text
    end

    def parse
      todos()
      
      get_variables()
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
    
    def todos
      replace(/<!-- @todo (.*?) -->/) do |tag, line_number|
        @todos ||= []
        @todos << {:line => line_number, :tag => tag}
        ""
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
          ""
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
          self.variables[variable_name] = variable_declaration.split(" ")[1]
          ""
        elsif self.variables[variable_name] || default
          self.variables[variable_name] || default
        else
          raise "Variable <strong>#{h variable_name}</strong> wasn't set!"
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
              raise "Includes: Can't include <strong>#{h tag}</strong> because <strong>#{h tag}</strong> isn't set."
            end
            
            tag = variable_value
          end
          
          file = find_file(tag, 'html')
          
          if file
            @hammer_project.parser_for_hammer_file(file).to_html()
          else
            raise "Includes: File <strong>#{h tag}</strong> couldn't be found."
          end
        end.compact.join("\n")
      end
    end

    def reload_tags
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
        file = find_file(File.basename(tag, ".*"), File.extname(tag)[1..-1])
        
        if !file
          raise "Path tags: <strong>#{h tag}</strong> couldn't be found."
        end
        
        them = Pathname.new(file.finished_filename)
        me = Pathname.new(File.dirname(filename))
        them.relative_path_from(me)
      end
    end

    def stylesheet_tags
      @included_stylesheets ||= []
      imported_results = []
      self.replace(/<!-- @stylesheet (.*?) -->/) do |tagged_path, line_number|
        tagged_path = tagged_path.gsub("<!-- @stylesheet ", "").gsub("-->", "").strip
        files = tagged_path.split(" ")
        results = []
        tags = []
        
        files.each do |filename|
          matches = find_files(filename, 'css')
          
          if matches == nil || matches.length == 0
            raise "Stylesheet tags: <strong>#{h tagged_path}</strong> couldn't be found."
          end
          
          matches.each do |file|
            them = Pathname.new(file.finished_filename)
            me = Pathname.new(File.dirname(self.filename))
            path = them.relative_path_from(me)
            if !@included_stylesheets.include?(path) && !File.basename(path).start_with?("_")
              @included_stylesheets << path
              tags << "<link rel='stylesheet' href='#{path}'>"
            end
          end
        end
        tags.compact.join("\n")
      end
    end
    
    def javascript_tags
      @included_javascripts ||= []
      imported_results = []
      self.replace(/<!-- @javascript (.*?) -->/) do |tagged_path, line_number|
        tagged_path = tagged_path.gsub("<!-- @javascript ", "").gsub("-->", "").strip
        files = tagged_path.split(" ")
        results = []
        tags = []
        files.each do |filename|
          matches = find_files(filename, 'js')
          
          if matches == nil || matches.length == 0
            raise "Javascript tags: <strong>#{h tagged_path}</strong> couldn't be found."
          end
          
          matches.each do |file|
            them = Pathname.new(file.finished_filename)
            me = Pathname.new(File.dirname(self.filename))
            path = them.relative_path_from(me)
            if !@included_javascripts.include?(path) && !File.basename(path).start_with?("_")
              @included_javascripts << path
              tags << "<script src='#{path}'></script>"
            end
          end
        end
        tags.compact.join("\n")
      end
    end
    
    def current_tags
      # If we don't have any links to the current page, let's get outta here real fast.
      # Otherwise, let's Amp it.
      return if !@hammer_file.finished_filename or !@text.match /href( )*\=( )*[" ']#{filename}["']/
      @text = Amp.parse(@text, @hammer_file.finished_filename, 'current')
    end
  end
  register_parser_for_extensions HTMLParser, ['html']
  register_parser_as_default_for_extensions HTMLParser, ['html']
end