#!/usr/bin/ruby

require "hammer2"
require "parsers"
require "hammer_file"
require "test/unit"
require "mocha/setup"
require "shoulda-context"

include Test::Unit

class HTMLParserTest < Test::Unit::TestCase
  def setup
    @hammer_project       = Hammer::Project.new
    @file                 = Hammer::HammerFile.new
    @hammer_project << @file
    @file.hammer_project  = @hammer_project
    @parser               = Hammer::HTMLParser.new(@hammer_project)
    @parser.hammer_file   = @file
  end

  def test_reload_tags
    @parser.text = "<html><!-- @reload --></html>"
    assert !@parser.parse().include?("@reload/<!-- @reload -->/")
  end

  def test_includes
    header = Hammer::HammerFile.new
    header.filename = "_header.html"
    header.text = "header"
    header.expects(:to_html).returns("header")
    @hammer_project << header

    @parser.text = "<html><!-- @include _header --></html>"
    @hammer_project.expects(:find_file).returns(header)
    
    assert_equal "<html>header</html>", @parser.parse()
  end
end

class HammerProjectTest < Test::Unit::TestCase
  context "a hammer project" do
    setup do
      @hammer_project = Hammer::Project.new
    end
    
    context "when empty" do
      should "compile" do
        assert @hammer_project.compile()
        assert_equal @hammer_project.compile().length, 0
      end
    end
    
    context "with files" do
      
      setup do
        @header = Hammer::HammerFile.new
        @header.filename = "_header.html"
        @header.text = "header"
        @hammer_project = Hammer::Project.new
        @hammer_project << @header
        Hammer::HammerParser.any_instance.stubs(:parse).returns(@header.text)
      end
      
      should "compile and return hammer files" do
        assert @hammer_project.compile()
        assert_equal @hammer_project.compile().length, 1
        assert_equal @hammer_project.compile().first, @header
        assert_equal @hammer_project.compile().first.text, @header.text
      end
      
      should "find the right parser for a file" do
        assert_equal Hammer.parser_for(@header.extension), Hammer::HTMLParser
      end
      
    end
  end
end

class HammerTest < Test::Unit::TestCase
  context "Hammer"  do
    should "find the right parser" do
      assert_equal Hammer.parser_for("html"), Hammer::HTMLParser
    end
  end
end

class TestingHammerProjectFindingFiles < Test::Unit::TestCase
  def setup
    @header = Hammer::HammerFile.new
    @header.filename = "_header.html"
    @header.text = "header"
    @hammer_project = Hammer::Project.new
    @hammer_project << @header
    @parser = Hammer::HTMLParser.new
  end

  def test_finding_files_finds_the_right_file
    
    html_file = Hammer::HammerFile.new
    html_file.filename = "_not_header.html"
    @hammer_project << html_file
    
    new_file = Hammer::HammerFile.new
    new_file.filename = "_not_header.js"
    @hammer_project << new_file
    
    assert_equal @hammer_project.find_files('_not_header', @parser), [html_file]
    assert_equal @hammer_project.find_files('_not_header_1', @parser), []
    assert_equal @hammer_project.find_files('_not_header_1', @parser), []
    assert_equal @hammer_project.find_files('_not_header', new_file.parser.new), [new_file]
  end

  def test_finding_files_finds_an_array_of_files
    assert_equal @hammer_project.find_files('_header', @parser), [@header]
  end

  def test_finding_file_finds_a_file
    assert_equal @hammer_project.find_file('_header', @parser), @header
  end
  
  def test_finding_file_finds_a_file
    assert_equal @hammer_project.find_file('_header', @parser), @header
  end
end

class CSSParserTest < Test::Unit::TestCase
  context "A CSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::CSSParser.new(@hammer_project)
    end
    
    should "exist" do
      assert @parser
    end
    
    context "with a CSS file" do
      
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "style.css"
      end
      
      should "parse CSS" do
        @file.text = "a {background: red}"
        
        assert_equal @file.parser, @parser.class
        @parser.hammer_file = @file
        @parser.text = @file.text
        
        result = @parser.parse()
        assert_equal @file.text, result
      end
      
      context "with other files" do
        
        setup do
          new_file = Hammer::HammerFile.new
          new_file.text = "I'm included."
          new_file.filename = "_include.css"
          @hammer_project << new_file
        end
        
        should "do include" do
          @parser.text =  "/* @include _include */"
          output = @parser.parse()
          assert output
          assert_equal "I'm included.", output
        end
      end
      
    end
  end
end

class SCSSParserTest < Test::Unit::TestCase
  context "A SCSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::SASSParser.new
    end
    should "parse SASS" do
      @parser.format = :scss
      @parser.text = "a { b { background: red; } }"
      assert_equal "a b {\n  background: red; }\n", @parser.parse()
    end
  end
end