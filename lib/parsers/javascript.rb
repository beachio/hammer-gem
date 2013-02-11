class Hammer
  
  class JSParser < HammerParser

    def to_js
    end

    def parse
      @text
    end
    
    def self.finished_extension
      "js"
    end
  end
  register_parser_for_extensions JSParser, ['js']
  register_parser_as_default_for_extensions JSParser, ['js']

  class CoffeeParser < HammerParser
    def to_javascript
    end

    def to_coffeescript
    end

    def parse
      @text
    end
    
    def self.finished_extension
      "js"
    end
  end
  register_parser_for_extensions CoffeeParser, ['js', 'coffee']
  register_parser_as_default_for_extensions CoffeeParser, ['coffee']

end