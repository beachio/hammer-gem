dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module Hammer

end

require 'hammer/build'
require 'hammer/project'
require 'hammer/parser'
require 'hammer/file'