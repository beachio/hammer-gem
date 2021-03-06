require 'hammer/test_helper'
require 'hammer/parser'
require 'hammer/parsers/coffee'
require 'coffee-script'

class CoffeeParserTest < Test::Unit::TestCase
  # include AssertCompilation
  context "A Coffee Parser" do
    setup do
      @options = {
        :input_directory => Dir.mktmpdir,
        :output_directory => Dir.mktmpdir,
        :cache_directory => Dir.mktmpdir
      }
      @parser = Hammer::CoffeeParser.new()

      @parser.stubs(:find_files).returns([])
      @parser.parse("a = -> b")
    end

    should "return JS for to_format with :js" do
      assert_equal @parser.to_format(:js), "(function() {\n  var a;\n\n  a = function() {\n    return b;\n  };\n\n}).call(this);\n"
    end

    should "return JS for to_format with :coffee" do
      assert_equal @parser.to_format(:coffee), "a = -> b"
    end

    should "Raise an error with bad Coffee" do
      assert_raises RuntimeError do |e, whatever|
        @parser.parse("a = function(){};")
      end
    end

    should "do includes" do
      file = create_file "test.coffee", "a -> 'abc'", @parser.directory
      @parser.stubs(:find_file).returns(file)
      # assert_equal "a -> true", @parser.parse("# @include test")
      assert @parser.parse("# @include test").include? 'abc'
    end

    should "transfer includes through to JavaScript" do
      file = create_file('other.js', "alert('a')")
      @parser.expects(:find_files).with('other', 'coffee').returns([file])
      text = @parser.parse("# @include other")
      assert text.include? "/* @include other */"
    end
  end
end