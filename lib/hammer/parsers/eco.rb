module Hammer
  class EcoParser < Parser

    register_as_default_for_extensions 'eco'
    accepts :eco
    returns_extension :js

    def parse(text)
      if !@original_text
        @original_text = text
        @text = text
        @text = Eco.compile(@text)
        raise "Parse called without @path!" unless @path
        name = File.basename(@path, '.*')
        @text = "if(undefined==window.JST){window.JST={};} window.JST[\"#{name}\"] = #{@text}"
      end
      @text
    end

    def to_format(format)
      if format == :js
        parse(@original_text)
      end
    end
  end
end