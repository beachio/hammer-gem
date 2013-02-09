require "cgi"
class Hammer

  class HammerParser

    def initialize(hammer_project = nil)
      @text = ""
      if hammer_project
        @hammer_project = hammer_project 
        @root_directory = hammer_project.root_directory
      end
    end

    def text=(text)
      @text = text
    end
    
    def text
      if @hammer_file && @text.to_s == ""
        @hammer_file.raw_text.to_s
      else
        @text
      end
    end
    
    def filename
      if @filename 
        return @filename
      elsif @hammer_file 
        return @hammer_file.filename
      end
    end
    
    attr_accessor :hammer_file

    def replace(regex, &block)
      lines = []
      if self.text.scan(regex).length > 0
        line_number = 0
        text.split("\n").each { |line| 
          line_number += 1
          lines << line.gsub(regex) { |match| 
            block.call(match, line_number)
          }
        }
        @text = lines.join("\n")
      end
      return
    end

    def parse
      raise "Base HammerParser#parse called"
    end
  end

  class HTMLParser < HammerParser
    
    def to_html
      @hammer_file.raw_text
    end

    def parse
      get_variables()
      includes()
      get_variables()
      reload_tags()
      stylesheet_tags()
      javascript_tags()
      current_tags()
      path_tags()
      output_variables()
      return @text
    end
    
    def variables
      @variables ||= {}
    end

    private
    
    def get_variables
      replace(/<!-- \$([^>]*) -->/) do |tag, line_number|
        variable_declaration = tag.gsub("<!-- $", "").gsub("-->", "").strip.split(" ")
        variable_name = variable_declaration[0]
        variable_value = variable_declaration[1..-1].join(' ')
        # If there's a |, this is a getter with a default!
        # TODO: Update the regex to disallow | characters.
        
        
        if variable_value.split("")[0] == "|" || variable_value == ""
          tag
        else
          self.variables[variable_name] = variable_value
          ""
        end
      end
    end
    
    def output_variables
      replace(/<!-- \$([^>]*) -->/) do |tag, line_number|
        
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
          raise "Variable <strong>#{CGI.escapeHTML variable_name}</strong> wasn't set!"
        end
      end
    end
    
    def includes
      lines = []
      replace(/<!-- @include (\S*) -->/) do |tag, line_number|
        tags = tag.gsub("<!-- @include ", "").gsub("-->", "").strip.split(" ")
        tags.map do |tag|
          if (tag.split("")[0] == "$")
            variable_value = variables[tag[1..-1]]
            raise "Variable #{tag} was not set!" if !variable_value
            tag = variable_value
          end
          file = @hammer_project.find_file(tag, 'html')
          Hammer.parser_for_hammer_file(file).to_html()
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
      replace(/<!-- @path (\S*) -->/) do |tag, line_number|
        tag = tag.gsub("<!-- @path ", "").gsub("-->", "").strip
        file = @hammer_project.find_file(File.basename(tag, ".*"), File.extname(tag))
        them = Pathname.new(file.filename)
        me = Pathname.new(File.dirname(filename))
        them.relative_path_from(me)
      end
    end

    def stylesheet_tags
      @included_stylesheets ||= []
      imported_results = []
      self.replace(/<!-- @stylesheet (.*) -->/) do |tagged_path, line_number|
        tagged_path = tagged_path.gsub("<!-- @stylesheet ", "").gsub("-->", "").strip
        files = tagged_path.split(" ")
        results = []
        tags = []
        files.each do |filename|
          matches = @hammer_project.find_files(filename, 'css')
          raise "Stylesheet file <strong>\"#{tagged_path}\"</strong> couldn't be found." if matches == nil || matches.length == 0
          matches.each do |file|
            them = Pathname.new(file.filename)
            me = Pathname.new(File.dirname(self.filename))
            path = them.relative_path_from(me)
            if !@included_stylesheets.include? path
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
      self.replace(/<!-- @javascript (.*) -->/) do |tagged_path, line_number|
        tagged_path = tagged_path.gsub("<!-- @javascript ", "").gsub("-->", "").strip
        files = tagged_path.split(" ")
        results = []
        tags = []
        files.each do |filename|
          matches = @hammer_project.find_files(filename, self)
          raise "Javascript file <strong>\"#{tagged_path}\"</strong> couldn't be found." if matches == nil || matches.length == 0
          matches.each do |file|
            them = Pathname.new(file.filename)
            me = Pathname.new(File.dirname(self.filename))
            path = them.relative_path_from(me)
            if !@included_javascripts.include? path
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
      return if !filename or !@text.match /href( )*\=( )*[" ']#{filename}["']/
      @text = Amp.parse(@text, filename, 'current')
    end
    
  end
  register_parser_for_extensions HTMLParser, ['html']
  register_parser_as_default_for_extensions HTMLParser, ['html']


  class CSSParser < HammerParser

    def to_css
      # puts "Raw text: #{@raw_text}"
      @hammer_file.raw_text
    end

    def parse
      includes
      clever_paths
      return @text
    end

  private

    def includes
      lines = []
      replace(/\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          file = @hammer_project.find_file(tag, 'css')
          Hammer.parser_for_hammer_file(file).to_css()
        end
        a.compact.join("\n")
      end
    end

    def clever_paths
    end

  end
  register_parser_for_extensions CSSParser, ['css']
  register_parser_as_default_for_extensions CSSParser, ['css']

  require "sass"
  class SASSParser < HammerParser
    
    def format=(format)
      @format = format.to_sym
    end

    def to_css
    end

    def to_css
    end

    def to_scss
    end
    
    def to_sass
    end

    def parse
      semicolon = @format == :scss ? ";\n" : "\n"
      @text = ["@import 'bourbon'", "@import 'bourbon-deprecated-upcoming'", @text].join(semicolon)
      
      # Dir.chdir(@directory) # will be required
      @text = Sass::Engine.new(@text, options).render()  
      @text
    end
    
    private
    
    def load_paths
      [
        (@root_directory rescue nil),
        File.expand_path("./vendor/gems/bourbon-*/app/assets/stylesheets"),
      ].compact
    end

    def options
      {
        :syntax => @format, 
        :load_paths => load_paths,
        :relative_assets => true,
        # :cache_location => @hammer_project.sass_cache_directory,
        :sass => sass_options
      }
    end
    
    def sass_options
      { :quiet => true, :logger => nil }
    end

  end
  register_parser_for_extensions SASSParser, ['sass', 'scss', 'css']
  register_parser_as_default_for_extensions SASSParser, ['sass', 'scss']

  class JSParser < HammerParser

    def to_js
    end

    def parse
    end

  end
  register_parser_for_extensions JSParser, ['js']
  register_parser_as_default_for_extensions JSParser, ['js']

  class CoffeeParser < HammerParser

    def to_javascript
    end

    def to_coffeescript
    end

    def parse
    end

  end
  register_parser_for_extensions CoffeeParser, ['js', 'coffee']
  register_parser_as_default_for_extensions CoffeeParser, ['coffee']

end