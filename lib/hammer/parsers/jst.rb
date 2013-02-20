class Hammer
  class JSTParser < HammerParser
    def to_javascript
      parse
    end
    
    def to_do_regex
      /\/* @todo (.*) \*\/|\/\/ @todo (.*)/
    end

    def parse
      @text = EJS.compile(@text)
      name = File.basename(@hammer_file.filename, '.*')
      @text = "if(undefined==window.JST){window.JST={};} window.JST[\"#{name}\"] = #{@text}"
    end

    def self.finished_extension
      "js"
    end
  end
  register_parser_for_extensions JSTParser, ['jst']
  register_parser_as_default_for_extensions JSTParser, ['jst']

  class EcoParser < HammerParser
    def parse
      @text = Eco.compile(@text)
      name = File.basename(@hammer_file.filename, '.*')
      @text = "if(undefined==window.JST){window.JST={};} window.JST[\"#{name}\"] = #{@text}"
    end

     def self.finished_extension
       "js"
     end
  end
  register_parser_for_extensions EcoParser, ['eco', 'js']
  register_parser_as_default_for_extensions EcoParser, ['eco']
end