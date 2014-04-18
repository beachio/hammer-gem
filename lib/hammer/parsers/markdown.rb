require 'kramdown'

module Hammer
  class MarkdownParser < Parser

    accepts :md
    returns :html

    def self.finished_extension
      "html"
    end

    def to_html
      # TODO: Make the other to_format calls work like this with setting @text in parse(text)?
      parse(@text)
    end
    
    def to_markdown
      @raw_text
    end
    
    def parse(text)
      @text = text
      text = convert(text)
      text = text[0..-2] if text.end_with?("\n")
      text
    end
    
    private
    
    def options
      {:auto_ids => false}
    end
    
    def convert(markdown)
      doc = Kramdown::Document.new(markdown, options).to_html
    end
    
  end
end