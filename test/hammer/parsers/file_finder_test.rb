#!/usr/bin/env ruby
require "test_helper"
require 'lib/hammer/parsers/file_finder'

class FileFinderTest < Test::Unit::TestCase

  class Thing
    include Hammer::FileFinder
  end

  setup do
    @object = Thing.new
  end

  def test_find_files
    @object.filenames = ['index.html']
    assert_equal @object.find_files('index', 'html'), ['index.html']
  end

end