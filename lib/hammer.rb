dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'pathname'

root = Pathname.new(__FILE__).expand_path + '..' + '..'

$LOAD_PATH.unshift root
$LOAD_PATH.unshift root + 'lib'

# Development gems take precedence
$LOAD_PATH.unshift root + 'vendor' + 'production' + 'bundle'
$LOAD_PATH.unshift root + 'vendor' + 'bundle'

module Hammer

end

require 'bundler/setup'

require 'hammer/build'
require 'hammer/project'
require 'hammer/parser'
require 'hammer/file'