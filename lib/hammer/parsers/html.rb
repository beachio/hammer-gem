require "amp"

module Hammer
  class HTMLParser < Parser

    RELOADER_SCRIPT = "
        <!-- Hammer reload -->
          <script>
            setInterval(function(){
              try {
                if(typeof ws != 'undefined' && ws.readyState == 1){return true;}
                ws = new WebSocket('ws://'+(location.host || 'localhost').split(':')[0]+':35353')
                ws.onopen = function(){ws.onclose = function(){document.location.reload()}}
                window.onbeforeunload = function() { ws = nil }
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
    @@cached_files = {}
    
    def to_html
      @text = @hammer_file.raw_text
      get_variables()
      includes()
      @text
    end

    def parse
      @text ||= ""
      get_variables()
      path_tags()
      includes()
      placeholders()
      get_variables()
      reload_tags()
      stylesheet_tags()
      javascript_tags()
      path_tags()
      output_variables()
      current_tags()
      ensure_text_has_no_leading_blank_lines()
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
      replace(/<!-- @placeholder (.*?) -->/) do |tag, line_number|
        options = tag.gsub("<!-- @placeholder ", "").gsub("-->", "").strip.split(" ")
        
        dimensions = options[0]
        text = ""
        alt = 'Placeholder Image'
        
        if options[1]
          text = options[1..-1].join(" ")
          alt = text.gsub('"', '')
          text = "&text=#{CGI.escape(text)}"
        end
        
        x = dimensions.split('x')[0]
        y = dimensions.split('x')[1] || x
        
        begin
          "<img src='http://placehold.it/#{x}x#{y}#{text}' width='#{x}' height='#{y}' alt='#{alt}' />"
        end
      end
      
      replace(/<!-- @kitten (\S*) -->/) do |tag, line_number|
        dimensions = tag.gsub("<!-- @kitten ", "").gsub("-->", "").strip
        x = dimensions.split('x')[0]
        y = dimensions.split('x')[1]
        "<img src='http://placekitten.com/#{x}/#{y}' width='#{x}' height='#{y}' alt='Meow' />"
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

        has_spaces = variable_declaration.include?(' ')

        variable_name = variable_declaration.split(" ")[0]
        variable_value = variable_declaration.split("|")[1..-1].join("|").strip rescue false

        is_a_getter_with_a_default = variable_declaration.split(" ")[1] == "|"
        if is_a_getter_with_a_default
          default = variable_declaration.split("|")[1..-1].join("|").strip rescue false
        end
        
        if has_spaces && !is_a_getter_with_a_default
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
      while text.match /<!-- @include (.*?) -->/
        
        replace(/<!-- @include (.*?) -->/) do |tags, line_number|
          tags = tags.gsub("<!-- @include ", "").gsub("-->", "").strip.split(" ")
          
          tags.map do |tag|
            
            if (tag.start_with? "$")
              variable_value = variables[tag[1..-1]]
              raise "Includes: Can't include <b>#{h tag}</b> because <b>#{h tag}</b> isn't set." unless variable_value
              
              tag = variable_value
            end
            
            file = find_file_with_dependency(tag, 'html')

            raise "Includes: File <b>#{h tag}</b> couldn't be found." unless file

            parser = Hammer::Parser.for_hammer_file(file)
            next unless parser
            parser.variables = self.variables
            
            begin
              parser.parse()
            rescue Hammer::Error => e
              e.hammer_file = file
              raise e
            end
            
            parser = Hammer::Parser.for_hammer_file(file)
            parser.variables = self.variables

            self.variables = self.variables.merge(parser.variables)
            parser.to_html()

          end.compact.join("\n")
        end
      end
    end

    def reload_tags
      if optimized
        @text = text.gsub(/<!-- @reload -->/, "")
      else
        @text = text.gsub(/<!-- @reload -->/, RELOADER_SCRIPT)
      end
    end
    
    def alternative_path_tags
      replace(/['|"]@path (.*?)['|"]/) do |tag, line_number|
        filename = tag[6..-2]
        
        filename = get_variable(filename) if filename.split("")[0] == "$"
        filename = filename.strip
        
        file = find_file(filename)
        if !file
          raise "Path tags: <b>#{h filename}</b> couldn't be found."
        else
          [tag.split("")[0], path_to_file(file), tag.split("")[-1]].join()
        end
      end
    end
    
    def path_tags
      replace(/<!-- @path (.*?) -->/) do |tag, line_number|
        filename = tag.gsub("<!-- @path ", "").gsub("-->", "").strip
  
        filename = get_variable(filename) if filename.split("")[0] == "$"
        filename = filename.strip
        file = find_file(filename)

        if !file
          raise "Path tags: <b>#{h filename}</b> couldn't be found."
        else
          path_to_file(file)
        end
      end
      alternative_path_tags
    end
    
    def get_variable(variable_name)

      @variables ||= {}

      if variable_name.split("")[0] == "$"
        variable_name = variable_name.split("")[1..-1].join("")
      end
      variable_value = @variables[variable_name]
      if !variable_value
        raise "Variable #{variable_name} wasn't set!"
      end
      return variable_value
    end

    def stylesheet_tags
      @included_stylesheets ||= []
      
      self.replace(/<!-- @stylesheet (.*?) -->/) do |tagged_path, line_number|
        results, tags, hammer_files, paths = [], [], [], [], []
        
        filenames = tagged_path.gsub("<!-- @stylesheet ", "").gsub("-->", "").strip.split(" ")
        
        filenames.each do |filename|
          filename = get_variable(filename) if filename.split("")[0] == "$"
          
          matching_files = find_files_with_dependency(filename, 'css')
          
          # if !filename.include? "*"
          #   matching_files = [matching_files[0]]
          # end
          
          raise "Stylesheet tags: <b>#{h filename}</b> couldn't be found." if matching_files.empty?
          hammer_files += matching_files
        end

        hammer_files_to_tag = []
        hammer_files.each do |file|
          
          next if file.is_a_compiled_file
          next if File.basename(file.filename).start_with?("_")
          
          path = path_to_file(file)
          
          next if @included_stylesheets.include?(path) 
          @included_stylesheets << path
          hammer_files_to_tag << file
          paths << path
        end
        
        if optimized
          file = add_file_from_files(hammer_files_to_tag, :css)
          "<link rel='stylesheet' href='#{path_to_file(file)}'>" if file
        else
          paths.map {|path| "<link rel='stylesheet' href='#{path}'>"}.compact.join("\n")
        end
      end
    end
    
    def add_file_from_files(files, format)
      return false if files == []
      # return false if files.collect(&:error) != []
      contents = []
      
      key = files.collect(&:filename).join(':') + ":#{format}"
      return @@cached_files[key] if @@cached_files[key]
      
      files.each do |file|
        contents << Hammer::Parser.for_hammer_file(file).to_format(format)
        if format == :js
          contents << ";"
        end
      end
      contents = contents.join("\n\n\n\n")
      filename = Digest::MD5.hexdigest(contents)
      file = add_file("#{filename}.#{format}", contents)
      file.source_files = files
      
      @@cached_files[key] = file
      
      file
    end
        
    def javascript_tags
      @included_javascripts ||= []
      
      self.replace(/<!-- @javascript (.*?) -->/) do |tagged_path, line_number|
        results, tags, hammer_files, paths = [], [], [], [], []
        
        filenames = tagged_path.gsub("<!-- @javascript ", "").gsub("-->", "").strip.split(" ")
        
        filenames.each do |filename| 
          filename = get_variable(filename) if filename.split("")[0] == "$"
          matching_files = find_files_with_dependency(filename, 'js')
          raise "Javascript tags: <b>#{h filename}</b> couldn't be found." if matching_files.empty?
          hammer_files += matching_files
        end
                
        hammer_files_to_tag = []
        hammer_files.each do |file|
          
          next if file.is_a_compiled_file
          next if File.basename(file.filename).start_with?("_")
          
          path = path_to_file(file)
          
          next if @included_javascripts.include?(path) 
          @included_javascripts << path
          hammer_files_to_tag << file
          paths << path
        end        
        if optimized
          file = add_file_from_files(hammer_files_to_tag, :js)
          "<script src='#{path_to_file(file)}'></script>" if file
        else
          paths.map {|path| "<script src='#{path}'></script>"}.compact.join("\n")
        end
      end
    end
    
    def current_tags
      # Otherwise, let's Amp it.
      # if @hammer_file
      if filename
        @text = Amp.compile(@text, File.basename(filename), 'current')
      end
      # end
    end
    
    def ensure_text_has_no_leading_blank_lines
      @text ||= ""
      while text.split(/\n|\t|\r/)[0] == ""
        @text = text[1..-1]
      end
    end
    
  end
  Hammer::Parser.register_for_extensions HTMLParser, ['html']
  Hammer::Parser.register_as_default_for_extensions HTMLParser, ['html']
end