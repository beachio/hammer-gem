require "execjs"
require "coffee-script"
require "eco"

module Hammer
  
  class JSParser < Parser

    def to_javascript
      parse
    end
    
    def to_format(format)
      if format == :js
        @text
      end
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
          
          raise "Included file <strong>#{h tag}</strong> couldn't be found." unless file
          
          Hammer::Parser.for_hammer_file(file).to_javascript()
        end
        a.compact.join("\n")
      end
    end
    
  end
  Hammer::Parser.register_for_extensions JSParser, ['js']
  Hammer::Parser.register_as_default_for_extensions JSParser, ['js']

  class CoffeeParser < Parser
    
    def to_javascript
      parse()
    end
    
    def to_format(format)
      if format == :js
        to_javascript
      elsif format == :coffee
        to_coffeescript
      end
    end

    def to_coffeescript
      @text
    end

    def parse
      includes()
      @text = CoffeeScript.compile @text
      replace_includes()
      @text
    rescue ExecJS::ProgramError, ExecJS::RuntimeError => error
      line = error.message.scan(/on line ([0-9]*)/).flatten.first.to_s rescue nil
      message = error.message.split("Error: ")[1]
      message = "Coffeescript Error: #{message}"
      @hammer_file.error = Hammer::Error.new(message, line)
      raise @hammer_file.error
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
          
          raise "File not found: <strong>#{h tag}</strong>" unless file
          
          parser = Hammer::Parser.for_hammer_file(file)
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
  Hammer::Parser.register_for_extensions CoffeeParser, ['coffee']
  Hammer::Parser.register_as_default_for_extensions CoffeeParser, ['coffee']

end