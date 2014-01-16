require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'pathname'
require 'open3'

# This tests the actual command line syntax.
class HammerGemIntegrationTest < Test::Unit::TestCase

  def integrate(input_directory, optimized = false)

    output_directory = Dir.mktmpdir('Build')
    cache_directory  = Dir.mktmpdir('cache')

    output = nil
    error = nil
    status = nil

    filename = File.dirname(File.dirname(File.dirname(__FILE__)))
    filename = File.join(filename, 'hammer_time.rb')

    args = ['/usr/bin/ruby', filename, cache_directory,
            input_directory, output_directory]
    args << 'PRODUCTION' if optimized

    Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
      output = stdout.read
      error = stderr.read
    end

    return output
  end

  def test_integration
    dirs = functional_test_directories
    dirs.each do |dir|
      dir = File.join(dir, 'input')
      output = integrate(dir)
      assert output.length > 0
    end
  end

end