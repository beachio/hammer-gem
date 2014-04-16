require 'lib/hammer/parsers/extensions'

module Hammer
  class CSSParser < Parser

    accepts :css
    returns_extension :css
    
    def parse(text)
      return text
    end

    def optimize(text)
      return text
    end

  end
end