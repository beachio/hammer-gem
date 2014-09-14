require 'pathname'

module Hammer
  class Error < SyntaxError; end

  def self.version
    File.open(File.join File.dirname(File.dirname(File.dirname(__FILE__))), "VERSION").read || "?"
  rescue => e
    "??"
  end
end

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

Encoding.default_internal = Encoding::UTF_8 if defined?(Encoding)
Encoding.default_external = Encoding::UTF_8 if defined?(Encoding)

root = Pathname.new(__FILE__).expand_path + '..' + '..' + '..'
$LOAD_PATH.unshift root
$LOAD_PATH.unshift root + 'lib'

# # Development gems take precedence
$LOAD_PATH.unshift root + 'vendor' + 'bundle'
$LOAD_PATH.unshift root + 'vendor' + 'production' + 'bundle'

module Hammer; end
require 'bundler/setup'
require 'slim'