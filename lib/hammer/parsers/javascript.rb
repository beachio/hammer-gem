class Hammer
  
  class JSParser < HammerParser

    def to_javascript
      parse
    end

    def parse
      includes()
      @text
    end
    
    def self.finished_extension
      "js"
    end
    
  private
    
    def includes
      lines = []
      replace(/\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          file = find_file(tag, 'js')
          Hammer.parser_for_hammer_file(file).to_javascript()
        end
        a.compact.join("\n")
      end
    end
    
  end
  register_parser_for_extensions JSParser, ['js']
  register_parser_as_default_for_extensions JSParser, ['js']

  class CoffeeParser < HammerParser
    def to_javascript
      parse()
    end

    def to_coffeescript
      @text
    end

    def parse
      includes()
      @text = CoffeeScript.compile @text
      replace_includes()
      @text
    end
    
    def replace_includes
      replace(/__hammer_include\((.*)\)/) do |invocation, line_number|
        file = invocation.gsub("__hammer_include(", "")[0..-2]
        "/* @include #{file} */"
      end
    end
    
    def self.finished_extension
      "js"
    end
    
    def includes
      lines = []
      replace(/# @include (.*)/) do |invocation, line_number|
        tags = invocation.gsub("# @include ", "").strip.split(" ")
        a = tags.map do |tag|
          file = find_file(tag, 'coffee')
          raise "File not found: #{tag} on line #{line_number} of #{filename}" unless file
          parser = Hammer.parser_for_hammer_file(file)
          if parser.respond_to? :to_coffeescript
            parser.to_coffeescript()
          else
            "__hammer_include(#{tag})"
          end
        end
        a.compact.join("\n")
      end
    end
    
  end
  register_parser_for_extensions CoffeeParser, ['js', 'coffee']
  register_parser_as_default_for_extensions CoffeeParser, ['coffee']

end