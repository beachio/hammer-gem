# This file is used by the Hammer app to run the testing command.
# It's just a wrapper around rake test.
# TODO: Remove "ruby test/tests.rb" from the XCode app and replace with "rake test"
# and release it and make sure everybody's using it before removing this.

require 'rubygems'
require 'rake'


ruby_version = RUBY_VERSION.to_f >= 2.0 ? '2.0.0' : '1.8'
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/vendor/*/bundle/ruby/#{ruby_version}/gems/*/lib")
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/vendor/*/bundle/ruby/#{ruby_version}/bundler/gems/*/lib")
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/lib")
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/bin")

app = Rake.application
app.init
app.load_rakefile
app['test'].invoke