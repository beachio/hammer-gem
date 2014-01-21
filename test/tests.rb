# This file is used by the Hammer app to run the testing command.
# It's just a wrapper around rake test.
# TODO: Remove "ruby test/tests.rb" from the XCode app and replace with "rake test"
# and release it and make sure everybody's using it before removing this.

require 'rake'
app = Rake.application
app.init
app.load_rakefile
app['test'].invoke