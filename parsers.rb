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
      @text ? @text : @hammer_file.raw_text
    end
    
    def filename
      @filename ? @filename : @hammer_file.filename
    end

    def hammer_file=(hammer_file)
      @hammer_file = hammer_file
    end

    def replace(regex, &block)
      lines = []
      if @text.scan(regex).length > 0
        line_number = 0
        @text.split("\n").each { |line| 
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
      @raw_text
    end

    def parse
      reload_tags()
      includes()
      stylesheet_tags()
      javascript_tags()
      return @text
    end

    private
    
    def variables
      @file.variables
    end

    def includes
      lines = []
      replace(/<!-- @include (\S*) -->/) do |tag, line_number|
        tags = tag.gsub("<!-- @include ", "").gsub("-->", "").strip.split(" ")
        tags.map do |tag|
          @hammer_project.find_file(tag, self).to_html
        end.join("\n")
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
      @text = @text.gsub(/<!-- @reload -->/, reloader_script)
    end

    def stylesheet_tags
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
        tags.join("\n")
      end
    end
  end
  register HTMLParser, "html"


  class CSSParser < HammerParser

    def to_css
      @text
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
        tags.map do |tag|
          file = @hammer_project.find_file(tag, self)
          Hammer.parser_for_hammer_file(file).to_css()
        end.join("\n")
      end
    end

    def clever_paths
    end

  end
  register CSSParser, "css"

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
  register SASSParser, "sass"
  register SASSParser, "scss"

  class JSParser < HammerParser

    def to_js
    end

    def parse
    end

  end
  register JSParser, "js"

  class CoffeeParser < HammerParser

    def to_javascript
    end

    def to_coffeescript
    end

    def parse
    end

  end
  register CoffeeParser, "coffee"

end