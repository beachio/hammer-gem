# require 'rdiscount'
require 'kramdown'
require 'parsers/html'
require 'htmlentities'

module Hammer
  class MarkdownParser < Parser

    accepts :md
    register_as_default_for_extensions :md
    returns :html

    def to_format(format)
      if format == :html
        parse(@markdown)
      elsif format == :md
        @markdown
      end
    end

    def options
      {:auto_ids => false}
    end

    def parse(text, filename=nil)
      @markdown = text
      text = convert(text)
      text = HTMLEntities.new.decode(text)
      parser = Hammer::HTMLParser.new(:path => @path)
      parser.directory = @directory
      text = parser.parse(text) # beforehand
      
      text = text[0..-2] while text.end_with?("\n")
      text
      
    end

    private

    def convert(markdown)
      # RDiscount.new(markdown, :smart).to_html
      Kramdown::Document.new(markdown, options).to_html
    end

  end
end