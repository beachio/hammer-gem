#!/usr/bin/env ruby
require "test_helper"
require 'parsers/modules/finding_files'

class FindingFilesTest < Test::Unit::TestCase

  class Thing
    include Hammer::FindingFiles
  end

  setup do
    @object = Thing.new
  end

  def test_find_files
    @object.stubs(:filenames).returns(['index.html', 'index.js', '_include.html'])
    {
      ['index', 'html'] => ['index.html'],
      ['index', 'js'] => ['index.js'],
      ['index', 'css'] => [],
      ['*', 'html'] => ['index.html', '_include.html'],
      ['include', 'html'] => ['_include.html']
    }.each do |set, result|
      query, extension = set
      assert_equal @object.find_files(query, extension), result
    end
  end

end