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
  end
end