require 'hammer/parsers/html'

module Hammer
  class PHPParser < HTMLParser

    def self.finished_extension
      'php'
    end
  end

  Hammer::Parser.register_for_extensions PHPParser, ['php']
  Hammer::Parser.register_as_default_for_extensions PHPParser, ['php']
end