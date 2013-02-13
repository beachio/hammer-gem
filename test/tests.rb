#!/usr/bin/ruby

require "rubygems"
require "test/unit"
require "mocha/setup"
require "shoulda-context"

include Test::Unit

require File.join(File.dirname(__FILE__), "../lib/hammer/include")

tests = Dir.glob(File.join(File.dirname(__FILE__), "*.rb")) - [__FILE__]

tests.each { |file|
  require file
}
