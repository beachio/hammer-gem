#!/usr/bin/ruby


['rubygems', 'test/unit', 'mocha/setup', 'shoulda-context'].each{|gem| require gem}
require File.join(File.dirname(__FILE__), "../lib/hammer/include")

Dir.glob(File.dirname(__FILE__)+"/*.rb").each { |file|
  require file unless file == __FILE__
}
include Test::Unit

