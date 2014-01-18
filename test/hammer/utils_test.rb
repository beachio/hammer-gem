#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'hammer/utils'

class UtilsTest < Test::Unit::TestCase
  
  def setup
  end

  def teardown
  end

  def test_output_filename_for

    mock_parser = Object.new
    mock_parser.expects('finished_extension').returns('html').at_least_once
    Hammer::Parser.expects('for_extension').returns([mock_parser]).at_least_once

    assert_equal Hammer::Utils.output_filename_for('index.html'), 'index.html'
    assert_equal Hammer::Utils.output_filename_for('assets/index.md'), 'assets/index.html'
  end

  def test_regex_for
    # Stub out the parser's possible_other_extensions_for_extension method
    Hammer::Utils.expects('possible_other_extensions_for_extension').with('html').returns(['a', 'b', 'c']).once

    assert_equal Hammer::Utils.regex_for("index.html"), /(^|\/)index\.(a|b|c)/
  end

  def test_long_paths
    Hammer::Utils.expects('possible_other_extensions_for_extension').with('html').returns(['a', 'b', 'c']).once
    assert_equal Hammer::Utils.regex_for("locations/1234567890/index.html").to_s, /(^|\/)locations\/1234567890\/index\.(a|b|c)/.to_s
  end

end
