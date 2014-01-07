lib_dir = File.dirname(__FILE__) + '/../lib'

require 'test/unit'
require 'fileutils'
$:.unshift lib_dir unless $:.include?(lib_dir)
require 'sass'
require 'mathn' if ENV['MATHN'] == 'true'
require 'tmpdir'
require 'byebug'
require 'mocha'
require 'shoulda'

require 'hammer'

Sass::RAILS_LOADED = true unless defined?(Sass::RAILS_LOADED)
Encoding.default_external = 'UTF-8' if defined?(Encoding)