#!/usr/bin/env ruby

require 'capture'
require 'hammer/test_helper'
require "tmpdir"
require "open3"
include Open3

class TestIntegration < Test::Unit::TestCase

  def ruby
    require 'rbconfig'
    bin = RbConfig::CONFIG["RUBY_INSTALL_NAME"] || RbConfig::CONFIG["ruby_install_name"]
    bin += (RbConfig::CONFIG['EXEEXT'] || RbConfig::CONFIG['exeext'] || '')
    ruby = File.join(RbConfig::CONFIG['bindir'], bin)
  end

  def build(input_directory, output_directory, optimized)
    output, error = nil

    cache_directory  = Dir.mktmpdir('cache')
    args = [ruby, 'hammer_time.rb', cache_directory, input_directory, output_directory]
    args << 'PRODUCTION' if optimized

    text = capture_stdout do
      assert Hammer::Build.new(
        :input_directory => input_directory,
        :output_directory => output_directory,
        :cache_directory => cache_directory,
        :optimized => optimized
      ).compile()
    end.string
    assert_equal "", text

    Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
      output = stdout.read
      error = stderr.read
    end

    FileUtils.remove_entry cache_directory

    if error != ""
      "[Integration tests] Error parsing the command:"
      puts "    #{args.join(' ')}"
    end

    assert_equal "", error
    assert output.length > 0

    return output, error
  end

  def test_compilation(optimized=false)
    output_directory = Dir.mktmpdir('Build')
    output, error = build(File.join('test', 'hammer', 'integration', 'case1'), output_directory, optimized)
    assert_equal "", error
    assert !output.include?("build-error")
    file = File.join output_directory, 'index.html'
    assert File.open(file).read.include? "<html>"
    FileUtils.remove_entry output_directory
    self.test_compilation(true) unless optimized
  end

def test_failure(optimized=false)
    input_directory  = File.join('test', 'hammer', 'integration', 'missingdirectory')
    output, error = build(input_directory, Dir.mktmpdir('Build'), optimized)
    assert_equal "", error
    assert output.include? "build-error"
    self.test_failure(true) unless optimized
  end

end