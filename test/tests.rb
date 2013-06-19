#!/usr/bin/ruby

require "rubygems"

dir = File.join(File.dirname(__FILE__), "vendor/gems/*")
Dir.glob(dir).each do |dir|
  d = File.directory?(lib = "#{dir}/lib") ? lib : dir
  $LOAD_PATH << d
end

require "test/unit"
require "mocha/setup"
require "shoulda-context"

include Test::Unit

require File.expand_path(File.join(File.dirname(__FILE__), "../lib/hammer/include"))

tests = Dir.glob(File.join(File.dirname(__FILE__), "*.rb")) - [__FILE__]

tests.each { |file|
  require File.expand_path(file)
}