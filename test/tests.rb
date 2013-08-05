#!/usr/bin/ruby

require 'pathname'
require Pathname.new('.').expand_path + 'lib' + 'hammer' + 'hammer'

require "test/unit"

# mocha uses Gem. This might change in a later version.
require "rubygems"
require "mocha/setup"

require "shoulda-context"

include Test::Unit

tests = Dir.glob(File.join(File.dirname(__FILE__), "*.rb")) - [__FILE__]
tests.each { |file|
  require File.expand_path(file)
}
