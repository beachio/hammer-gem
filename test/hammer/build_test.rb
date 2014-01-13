#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'hammer/build'

class BuildTest < Test::Unit::TestCase
  
  def setup
    @input_directory = Dir.mktmpdir
    @output_directory = Dir.mktmpdir
    @cache_directory = Dir.mktmpdir
    @build = Hammer::Build.new(:input_directory => @input_directory, 
                               :output_directory => @output_directory,
                               :cache_directory => @cache_directory)
  end

  def teardown
    FileUtils.rm_rf @input_directory
    FileUtils.rm_rf @output_directory
    FileUtils.rm_rf @cache_directory
  end

  def test_you_can_create_a_build
    assert @build
  end

  def test_a_build_compiles
    @build.compile do
      assert @build
    end
  end

end
