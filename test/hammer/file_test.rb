#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'hammer/build'

class HammerFileTest < Test::Unit::TestCase
  
  def setup
    @project_directory = Dir.mktmpdir
    @filename = 'index.html'
    @file_path = File.join(@project_directory, @filename)
    @file = Hammer::HammerFile.new filename: @filename, path: @file_path

    File.open(@file_path, 'w') do |file|
      file.write "Testing the file"
    end
  end

  def teardown
    FileUtils.rm_rf(@project_directory)
  end

  def test_a_file_can_be_created
    assert @file
  end

  def test_read_contents
    assert_equal @file.raw_text, "Testing the file"
  end

  # def test_paths
  #   @other_file = @file.dup
  #   @other_file.filename = 'two.html'
  #   assert_equal @file.path_to_file('two.html').to_s, 'two.html'
  # end

end
