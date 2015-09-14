module Hammer
  class EcoParser < Parser

    register_as_default_for_extensions 'eco'
    accepts :eco
    returns :js

    def parse(text, filename=nil)
      @original_text ||= text
      text = Eco.compile(text)
      raise "Parse called without path! Nothing to name the template." unless @path
      name = File.basename(@path, '.*')
      text = "if(undefined==window.JST){window.JST={};} window.JST[\"#{name}\"] = #{text}"
      text
    end

    def to_format(format)
      parse(@original_text) if format == :js
    end
  end
end