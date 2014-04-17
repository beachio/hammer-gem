require 'hammer/parsers/html'

module Hammer
  class PHPParser < HTMLParser

    def self.finished_extension
      'php'
    end
  end
end