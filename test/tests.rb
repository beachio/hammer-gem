#!/usr/bin/ruby

['rubygems', 'test/unit', 'mocha/setup', 'shoulda-context'].each{|gem| require gem}

['lib/include', 'hammer', 'hammer_file', 'parsers'].each{ |file|
  puts file
  require File.expand_path("../../#{file}", __FILE__)
}

Dir.glob(File.dirname(__FILE__)+"/**/*").each { |file|
  require file unless file == __FILE__
}

include Test::Unit