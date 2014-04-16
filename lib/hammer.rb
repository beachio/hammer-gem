require 'bundler/setup'

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'pathname'

root = Pathname.new(__FILE__).expand_path + '..' + '..'

$LOAD_PATH.unshift root
$LOAD_PATH.unshift root + 'lib'

# Development gems take precedence
$LOAD_PATH.unshift root + 'vendor' + 'production' + 'bundle'
$LOAD_PATH.unshift root + 'vendor' + 'bundle'

Encoding.default_internal = Encoding::UTF_8 if defined?(Encoding)
Encoding.default_external = Encoding::UTF_8 if defined?(Encoding)

module Hammer; end
require 'hammer/build'
require "hammer/hammer"
require "hammer/parser"

# parsers_path = File.join(File.dirname(__FILE__), 'parsers', '**/*.rb')
# Dir[parsers_path].each {|file| require file; puts file }