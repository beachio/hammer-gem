require "test_helper"
require "hammer/parser"
require "hammer/parsers/haml"

class TestHaml < Test::Unit::TestCase
  context "A HAML file parser" do
    setup do
      @parser = Hammer::HAMLParser.new
      def test(input, output)
        assert_equal output, @parser.parse(input)
      end
    end

    should "parse haml" do
      test "#hello Hi", "<div id='hello'>Hi</div>"
    end

    should "preserve comments" do
      test "/ Comment", "<!-- Comment -->"
    end

    should "paths" do
      test "/ @path include", "<!-- @path include -->"
    end

    should "indent_from_line" do
      lines = "this\n  is\n  a\n  line".split("\n")
      assert_equal ["this", "  is", "  a", "  line"], @parser.send(:indent_from_line, "    My line", lines, 2, 5)

      lines = "this\n         is\n          a\n       line".split("\n")
      assert_equal ["this", "         is", "          a", "            line"], @parser.send(:indent_from_line, "    My line", lines, 2, 5)
    end

  end

  context "A HAML file in a project" do

    setup do
      @parser = Hammer::HAMLParser.new(:path => "index.haml")
      def test(input, output)
        assert_equal output, @parser.parse(input)
      end
    end

    should "respond to to_format with :html and :haml" do
    	@parser.parse('Hello, world!')
    	assert_equal "Hello, world!", @parser.to_format(:html)
    	assert_equal "Hello, world!", @parser.to_format(:haml)
    end

    should "include an HTML file" do
      file = create_file('include.html', "My File!", @parser.directory)
      @parser.stubs(:find_file).returns(file)
      assert_equal "<!-- @include include -->", @parser.parse("/ @include include")
    end

    context "when parsing path tags" do
      setup do
        file = create_file('blog/index.haml', "<img src='<!-- @path logo.png -->' />", @parser.directory)
        logo = create_file('images/logo.png', "image", @parser.directory)
      end

      should "not replace HTML path tags" do
        assert_equal @parser.parse("<img src='<!-- @path logo.png -->' />"), "<img src='<!-- @path logo.png -->' />"
      end
    end

    context "with multiple-layer inheritance" do
      setup do
    #     @parser = Hammer::HTMLParser.new(@hammer_project)
    #     @file = Hammer::HammerFile.new(:filename => "index.haml", :hammer_project => @hammer_project)

        header = create_file 'header.haml', 'header', @parser.directory
        @parser.expects(:find_files).returns([header])

        def test(input, output)
          assert_equal output, @parser.parse(input)
        end

    #     @file.filename = "index.haml"
    #     @file.raw_text = "<!-- @include _first_level_include -->"
    #     @file.hammer_project = @hammer_project

    #     first_level_include = Hammer::HammerFile.new
    #     first_level_include.filename = "_first_level_include.haml"
    #     first_level_include.raw_text = "<!-- @include _second_level_include -->"
    #     @hammer_project << first_level_include

    #     second_level_include = Hammer::HammerFile.new
    #     second_level_include.filename = "_first_level_include.haml"
    #     second_level_include.raw_text = "Second level included!"
    #     @hammer_project << second_level_include

    #     @parser.expects(:find_files).returns(first_level_include)
      end

      should "have the right output" do
        test "/ @include _header", "header"

    #     @parser.hammer_file = @file
    #     text = @parser.parse()
    #     assert_equal "Second level included!", text
      end
    end
  end
end

class TestHamlStringInstanceMethods < Test::Unit::TestCase
  def test_number_of_tab_or_space_indents
    assert_equal 0, "This is a test".number_of_tab_or_space_indents
    assert_equal 1, " This is a test".number_of_tab_or_space_indents
    assert_equal 2, "  This is a test".number_of_tab_or_space_indents
    assert_equal 1, "	This is a test".number_of_tab_or_space_indents
    assert_equal 2, "		This is a test".number_of_tab_or_space_indents
  end

  def test_indentation_character
  	assert_equal "	", "		This is a test".indentation_character
  	assert_equal " ", "      This is a test".indentation_character
  end

  def test_indentation_in_last_line
  	assert_equal 1, "	\n	This is a test".indentation_in_last_line
  	assert_equal 6, "\n      This is a test".indentation_in_last_line
  end

  def test_array_of_lines_indented_by
  	assert_equal ["xYes"], "Yes".array_of_lines_indented_by("x")
  end

  def test_indentation_string
  	assert_equal "  ", "  Hello".indentation_string
  end
end

# class TestHamlHelper < Test::Unit::TestCase
# 	def test_path
# 		puts "Testing test_path on HamlHelper"
# 		klass = HAMLHelper.new
# 		klass.expects(:find_file).with("about").returns('about.haml')
# 		klass.expects(:path_to).with('about.haml').returns('about.haml')
# 		assert_equal klass.path("about"), 'about.haml'
# 	end
# end