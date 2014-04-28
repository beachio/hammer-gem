#!/usr/bin/env ruby

require 'hammer/test_helper'
require "tmpdir"
require "open3"
include Open3

class TestInvalidStuff < Test::Unit::TestCase

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

    Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
      output = stdout.read
      error = stderr.read
    end

    FileUtils.remove_entry cache_directory

    assert_equal "", error
    assert output.length > 0

    return output, error
  end

  def test_empty_directory(optimized=false)
    output, error = build(Dir.mktmpdir('input'), Dir.mktmpdir('Build'), optimized)
    self.test_empty_directory(true) unless optimized
    assert_equal "", error
  end

  def test_missing_directory(optimized=false)
    dir = Dir.mktmpdir("deleteme")
    FileUtils.rm_rf(dir)

    output, error = build(dir, Dir.mktmpdir('Build'), optimized)
    assert_equal "", error

    # assert output.include? "No file" # or something like that
    self.test_empty_directory(true) unless optimized
  end

end