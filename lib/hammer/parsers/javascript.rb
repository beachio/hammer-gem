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
          file = find_file_with_dependency(tag, 'js')
          
          raise "Included file <strong>#{h tag}</strong> couldn't be found." unless file
          
          Hammer::Parser.for_hammer_file(file).to_javascript()
        end
        a.compact.join("\n")
      end
    end
    
  end
  
  # Hammer::Parser.register_for_extensions JSParser, ['js']
  # Hammer::Parser.register_as_default_for_extensions JSParser, ['js']

end