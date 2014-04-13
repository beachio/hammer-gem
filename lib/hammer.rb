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

module Hammer

end

require 'bundler/setup'

# require 'hammer/build'
# require 'hammer/project'
# require 'hammer/parser'
# require 'hammer/file'

require "hammer/hammer"
require "hammer/parser"

parsers_path = File.join(File.dirname(__FILE__), 'parsers', '*')
parsers      = Pathname.glob(parsers_path)
parsers.each { |file| require "hammer/parsers/#{file.basename(file.extname)}" }