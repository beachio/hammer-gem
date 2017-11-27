require 'ejs'
require 'eco'

module Hammer
  class JSTParser < Parser

    register_as_default_for_extensions 'jst'
    accepts :jst
    returns :js

    def to_format(format)
      if format == :js
        parse(@text)
      end
    end
    
    def parse(text, filename=nil,test=nil)
      @text ||= text
      text = EJS.compile(text)
      name = File.basename(@path, '.*')
      "if(undefined==window.JST){window.JST={};} window.JST[\"#{name}\"] = #{text}"
    end
  end
end