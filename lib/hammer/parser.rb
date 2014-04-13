require 'lib/hammer/parsers/extensions'

module Hammer
  class Parser

    include ExtensionMapper

    def parse(text)
      return text
    end

  end
end