module Hammer
  class CoffeeParser < Parser

    accepts :coffee
    returns :js
    register_as_default_for_extensions :js
    attr_accessor :to_coffeescript
    
    def to_format(format)
      case format
      when :js
        parse(@text)
      when :coffee
        @text
      end
    end

    def parse(text=nil)
      text ||= @text
      @text ||= text

      text = includes text
      text = CoffeeScript.compile text
      text = replace_includes text

      text
    rescue ExecJS::ProgramError, ExecJS::RuntimeError => error
      line = error.message.scan(/on line ([0-9]*)/).flatten.first.to_s rescue nil
      message = error.message.split("Error: ")[1]
      message = "Coffeescript Error: #{message}"
      # TODO: Do something with line!
      raise message
    end
    alias_method :to_javascript, :parse

  private

    def replace_includes(text)
      return replace(text, /__hammer_include\((.*)\)/) do |invocation, line_number|
        file = invocation.gsub("__hammer_include(", "")[0..-2]
        "/* @include #{file} */"
      end
    end
    
    def includes(text)
      lines = []
      return replace(text, /# @include (.*)/) do |invocation, line_number|
        tags = invocation.gsub("# @include ", "").strip.split(" ")
        a = tags.map do |tag|

          file = find_file(tag, 'coffee')
          add_dependency(file)
          
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