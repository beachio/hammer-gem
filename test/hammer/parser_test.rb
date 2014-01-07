#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'hammer/parser'

module Hammer
  class DummyParser < Parser
    def self.finished_extension
      'dummy'
    end
  end

  class DummyTwoFirstParser < DummyParser
    def self.finished_extension
      'dummy2'
    end
  end
  class DummyTwoSecondParser < DummyParser
    def self.finished_extension
      'dummy2'
    end
  end
end

Hammer::Parser.register_for_extensions Hammer::DummyParser, ['dummy']
Hammer::Parser.register_as_default_for_extensions Hammer::DummyTwoFirstParser, ['dummy2']
Hammer::Parser.register_for_extensions Hammer::DummyTwoFirstParser, ['dummy2']
Hammer::Parser.register_for_extensions Hammer::DummyTwoSecondParser, ['dummy2']

class ParserTest < Test::Unit::TestCase
  
  def setup
    @project_options = {
      input_directory: Dir.mktmpdir,
      output_directory: Dir.mktmpdir,
      cache_directory: Dir.mktmpdir
    }
  end

  def teardown
    FileUtils.rm_rf @project_options[:input_directory]
    FileUtils.rm_rf @project_options[:output_directory]
    FileUtils.rm_rf @project_options[:cache_directory]
  end

  def test_parser_can_be_created_with_a_file
    # filename = File.join(@project_options[:input_directory], 'index.html')
    # File.open(filename, 'w') { |file| file.write 'a' }

    parser = Hammer::Parser.new
    assert parser
  end

  def test_parser_can_have_text
    parser = Hammer::Parser.new :text => "a"
    assert_equal parser.text, "a"
  end

  def test_parser_can_replace_text
    parser = Hammer::Parser.new :text => "This is my jam"
    parser.replace(/my/) { |match, line_number| "our" }
    assert_equal parser.text, "This is our jam"
  end

  def test_parser_can_be_found
    file = Hammer::HammerFile.new filename: 'index.html'
    assert Hammer::Parser.for_hammer_file(file)
  end

  def test_possible_other_extensions_for_extension_returns_the_correct_extensions
    assert_equal Hammer::Utils.possible_other_extensions_for_extension('css'), ["css", "sass", "scss"]
    assert_equal Hammer::Utils.possible_other_extensions_for_extension('js'), ["js", "coffee", "jst", "eco"]
  end

  def test_for_extension
    assert_equal [Hammer::DummyParser], Hammer::Parser.for_extension('dummy')
    assert_equal [Hammer::DummyTwoFirstParser, Hammer::DummyTwoSecondParser], Hammer::Parser.for_extension('dummy2')
  end

  def test_javascript_parsers
    assert_equal [Hammer::JSParser], Hammer::Parser.for_extension('js')
  end

  def test_all_parsers
    assert_includes Hammer::Parser.all, Hammer::DummyParser
  end

  def test_next_parser
    assert_equal Hammer::DummyTwoFirstParser.next_parser, Hammer::DummyTwoSecondParser
  end

end