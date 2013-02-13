#!/usr/bin/ruby

# require "./hammer"
# require "./parsers"
# require "./hammer_file"
# Dir['./lib/parsers/*'].each do |file|
#   require file
# end

require File.join(File.dirname(__FILE__), "lib/hammer/include")

require "rubygems"
require "test/unit"
require "mocha/setup"
require "shoulda-context"
