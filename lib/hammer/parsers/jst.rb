require 'ejs'
require 'eco'

module Hammer
  class JSTParser < Parser

    register_as_default_for_extensions 'jst'
    accepts :jst
    returns_extension :js

    def to_format(format)
      if format == :js
        parse()
      end
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
  # Hammer::Parser.register_for_extensions JSTParser, ['jst']
  # Hammer::Parser.register_as_default_for_extensions JSTParser, ['jst']

  class EcoParser < Parser

    register_as_default_for_extensions 'eco'
    accepts :eco
    returns_extension :js

    def parse
      @text = Eco.compile(@text)
      name = File.basename(@hammer_file.filename, '.*')
      @text = "if(undefined==window.JST){window.JST={};} window.JST[\"#{name}\"] = #{@text}"
    end

    def to_format(format)
      if format == :js
        parse()
      end
    end

     def self.finished_extension
       "js"
     end
  end
  # Hammer::Parser.register_for_extensions EcoParser, ['eco']
  # Hammer::Parser.register_as_default_for_extensions EcoParser, ['eco']
end