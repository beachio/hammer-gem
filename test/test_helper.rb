begin
  require "simplecov"
  SimpleCov.start do

    add_group 'Parsers', '/lib/hammer/parsers/*'
    add_group 'Templates', '/lib/hammer/templates'
    add_group 'Hammer', '/lib/hammer'

    ENV['COVERAGE'] = 'true'
    Rake::Task["test"].execute
  end
rescue LoadError
  # not installed
end

require 'fileutils'

lib_dir = File.dirname(__FILE__) + '/../lib'
$:.unshift lib_dir unless $:.include?(lib_dir)
require 'hammer/hammer'

require 'test/unit'
require 'sass'
require 'mathn' if ENV['MATHN'] == 'true'
require 'tmpdir'
require 'mocha/setup'
require 'shoulda'

Sass::RAILS_LOADED = true unless defined?(Sass::RAILS_LOADED)
Encoding.default_external = 'UTF-8' if defined?(Encoding)

def create_file(filename, contents, directory=nil)
  path = File.join(directory || Dir.mktmpdir, filename)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') do |file|
    file.print contents
  end
  path
end