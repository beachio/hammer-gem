require 'lib/hammer/parsers/extensions'

module Hammer
  class HTMLParser < Parser

    register_for_extension :html
    returns_extension :html
    
    def parse(text)
      return text
    end

  end
end