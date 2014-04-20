#!/usr/bin/env ruby

require 'hammer/test_helper'
require "tmpdir"
# Larry told me to use open3 instead of backticks.
require "open3"
include Open3

class TestIntegration < Test::Unit::TestCase

  def test_failure(optimized=false)

    input_directory  = File.join('test', 'hammer', 'integration', 'missingdirectory')
    output_directory = Dir.mktmpdir('Build')
    cache_directory  = Dir.mktmpdir('cache')
    
    output = nil
    error = nil
    status = nil
    
    args = ['/usr/bin/ruby', '-rubygems', 'hammer_time.rb', cache_directory,
            input_directory, output_directory]
    args << 'PRODUCTION' if optimized

    # Here's a thing. We're not checking wait_thread's exit status, 
    # because in Ruby 1.8.7 you don't get it. Sucks to be us!
    Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
      output = stdout.read
      error = stderr.read
    end
    
    assert_equal "", error
    assert output.length > 0
    assert output.include? "build-error" 

    self.test_failure(true) unless optimized
  end

  def test_compilation(optimized=false)

    input_directory  = File.join('test', 'hammer', 'integration', 'case1')
    output_directory = Dir.mktmpdir('Build')
    cache_directory  = Dir.mktmpdir('cache')

    output = nil
    error = nil
    status = nil

    # ruby = `which ruby`.gsub("\n", "")

    # require 'rbconfig'
    # bin = RbConfig::CONFIG["RUBY_INSTALL_NAME"] || RbConfig::CONFIG["ruby_install_name"]
    # bin += (RbConfig::CONFIG['EXEEXT'] || RbConfig::CONFIG['exeext'] || '')
    # ruby = File.join(RbConfig::CONFIG['bindir'], bin)

    args = ["/usr/bin/ruby", '-rubygems', 'hammer_time.rb', cache_directory, input_directory, output_directory]
    args << 'PRODUCTION' if optimized
    puts args.join(' ')

    Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
      output = stdout.read
      error = stderr.read
    end

    assert_equal "", error
    assert output.length > 0
    assert !output.include?("build-error")

    file = File.join output_directory, 'index.html'
    assert File.open(file).read.include? "<html>"

    FileUtils.remove_entry output_directory
    FileUtils.remove_entry cache_directory

    self.test_compilation(true) unless optimized
  end

end