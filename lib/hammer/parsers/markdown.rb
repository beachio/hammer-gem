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

    def quotes
      ["apos", "apos", "quot", "quot"]
    end

    def options
      {:auto_ids => false, :smart_quotes => quotes}
    end

    def parse(text, filename=nil)
      @markdown = text
      text = text.gsub(/<!--\s+(@|\$)[^-]+-->/m) do
        CGI.escapeHTML Regexp.last_match[0]
      end
      text = convert(text)
      text = text[0..-2] while text.end_with?("\n")
      CGI.unescapeHTML(text)
    end

    private

    def convert(markdown)
      meta = markdown.match(/<\s*meta.*\scharset/)
      header = ""
      if meta.nil?
        header = "<meta charset=\"utf-8\">"
      end
      header + Kramdown::Document.new(markdown, options).to_html
    end
  end
end
