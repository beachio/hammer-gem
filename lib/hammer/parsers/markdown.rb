class Hammer
  class MarkdownParser < HammerParser

    def self.finished_extension
      "html"
    end

    def to_html
      parse()
    end
    
    def to_markdown
      @raw_text
    end
    
    def parse
      convert(text)
    end
    
    private
    
    def options
      {:auto_ids => false}
    end
    
    def convert(markdown)
      doc = Kramdown::Document.new(markdown, options).to_html
    end
    
  end
  register_parser_for_extensions MarkdownParser, ['md']
  register_parser_as_default_for_extensions MarkdownParser, ['md']
end