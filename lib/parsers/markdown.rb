class Hammer
  class MarkdownParser < HammerParser
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
    
    def convert(markdown)
      Kramdown::Document.new(markdown).to_html
    end
    
  end
  register_parser_for_extensions MarkdownParser, ['md']
  register_parser_as_default_for_extensions MarkdownParser, ['md']
end