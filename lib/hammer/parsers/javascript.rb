require "execjs"
require "coffee-script"
require "eco"

module Hammer

  class JSParser < Parser

    accepts :js
    returns :js
    register_as_default_for_extensions :js

    def to_format(format)
      if format == :js
        parse(@text)
      end
    end

    def parse(text, filename=nil)
      @text = text

      text = includes(text)
      text
    end

  private

    def includes(text)
      lines = []

      replace(text, /\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          file = find_file_with_dependency(tag, 'js')

          raise "Included file <strong>#{h tag}</strong> couldn't be found." unless file

          # TODO: Create and parse in tests
          parse_file(file, :js)
        end
        a.compact.join("\n")
      end
    end

  end

end