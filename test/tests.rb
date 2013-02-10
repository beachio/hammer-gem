#!/usr/bin/ruby

## Let's start by $LOAD_PATHing all the directories inside vendor/gems/*/lib
["./vendor/gems/*", "../vendor/gems"].each do |directory|
  puts directory
  Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), directory)).each do |dir|
    d = File.directory?(lib = "#{dir}/lib") ? lib : dir
    $LOAD_PATH << d
  end
end

['rubygems', 'test/unit', 'mocha/setup', 'shoulda-context'].each{|gem| require gem}

['lib/include', 'hammer', 'hammer_file', 'parsers'].each{ |file|
  require File.expand_path("../../#{file}", __FILE__)
}

Dir.glob(File.dirname(__FILE__)+"/*.rb").each { |file|
  require file unless file == __FILE__
}

include Test::Unit