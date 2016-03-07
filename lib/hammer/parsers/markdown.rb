require 'kramdown'
require 'parsers/html'

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
      text = text.gsub(/<!--[^-]+-->/m) do
        CGI.escapeHTML Regexp.last_match[0]
      end
      @markdown = text
      text = convert(text)
      text = text[0..-2] while text.end_with?("\n")
      CGI.unescapeHTML(text)
    end

    private

    def convert(markdown)
      Kramdown::Document.new(markdown, options).to_html
    end
  end
end
