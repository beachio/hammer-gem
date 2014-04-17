require 'hammer/parsers/html'

module Hammer
  class PHPParser < HTMLParser

    accepts :php
    returns :php

  end
end