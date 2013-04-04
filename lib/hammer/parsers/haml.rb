class Hammer
    
  class HAMLParser < HammerParser

    def self.finished_extension
      "html"
    end

    def to_html
      parse
    end
    
    def to_haml
      @raw_text
    end
    
    def parse
      convert(text)
    rescue Haml::SyntaxError => e
      raise Hammer::Error.new(e.message, e.line)
    end
    
    private
    
    def convert(text)
      Haml::Engine.new(text).to_html  
    end
  end
  register_parser_for_extensions HAMLParser, ['haml']
  register_parser_as_default_for_extensions HAMLParser, ['haml']

end