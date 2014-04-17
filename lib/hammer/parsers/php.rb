require 'hammer/parsers/html'

module Hammer
  class PHPParser < HTMLParser

    accepts :php
    returns :php

    def self.finished_extension
      'php'
    end
  end
end