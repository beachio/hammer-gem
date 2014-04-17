module Hammer
  class CoffeeParser < Parser

    accepts :coffee
    returns :js
    register_as_default_for_extensions :js
    
    def to_javascript
      parse(@original_text)
    end
    
    def to_format(format)
      if format == :js
        to_javascript
      elsif format == :coffee
        to_coffeescript
      end
    end

    def to_coffeescript
      @original_text
    end

    def parse(text)
      @text = text
      @original_text = text
      includes()
      @text = CoffeeScript.compile @text
      replace_includes()
      @text
    rescue ExecJS::ProgramError, ExecJS::RuntimeError => error
      line = error.message.scan(/on line ([0-9]*)/).flatten.first.to_s rescue nil
      message = error.message.split("Error: ")[1]
      message = "Coffeescript Error: #{message}"
      # @hammer_file.error = Hammer::Error.new(message, line)
      # raise @hammer_file.error
      raise message
    end
    
    def replace_includes
      @text = replace(@text, /__hammer_include\((.*)\)/) do |invocation, line_number|
        file = invocation.gsub("__hammer_include(", "")[0..-2]
        "/* @include #{file} */"
      end
    end
    
    def self.finished_extension
      "js"
    end
    
    def includes
      lines = []
      @text = replace(@text, /# @include (.*)/) do |invocation, line_number|
        tags = invocation.gsub("# @include ", "").strip.split(" ")
        a = tags.map do |tag|

          file = find_files(tag, 'coffee')[0]
          # file = find_file_with_dependency(tag, 'coffee')
          
          raise "File not found: <strong>#{h tag}</strong>" unless file
          
          parser = Hammer::Parser.for_filename(file).last
          if parser.respond_to? :to_coffeescript
            parser.to_coffeescript(File.open(file).read)
          else
            "__hammer_include(#{tag})"
          end
        end
        a.compact.join("\n")
      end
    end
    
  end
end