lib_dir = File.dirname(__FILE__) + '/../lib'

require 'test/unit'
require 'fileutils'
require 'sass'
require 'mathn' if ENV['MATHN'] == 'true'
require 'tmpdir'
require 'mocha/setup'
require 'shoulda'

Sass::RAILS_LOADED = true unless defined?(Sass::RAILS_LOADED)
Encoding.default_external = 'UTF-8' if defined?(Encoding)

$:.unshift lib_dir unless $:.include?(lib_dir)
require 'hammer'