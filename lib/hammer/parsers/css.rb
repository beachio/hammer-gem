require 'lib/hammer/parsers/extensions'

module Hammer
  class CSSParser < Parser

    register_for_extension :css
    returns_extension :css
    
    def parse(text)
      return text
    end

  end
end