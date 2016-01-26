require 'hammer/test_helper'
require 'hammer/parser'
require 'hammer/parsers/haml'
require 'hammer/parsers/slim'

class SlimParserTest < Test::Unit::TestCase
  # include AssertCompilation
  context "A SLIM Parser" do
    setup do
      @parser = Hammer::SlimParser.new
      def test(input, output)
        assert_equal output, @parser.parse(input)
      end
    end

    should 'parse slim' do
      test '#hello.title Hi', '<div class="title" id="hello">Hi</div>'
    end

    should "preserve comments" do
      test '/!  Comment ', '<!-- Comment -->'
    end

    should 'paths' do
      test '/!  @path include ', '<!-- @path include -->'
    end

    # should "indent_from_line" do
    #   lines = "this\n  is\n  a\n  line".split("\n")
    #   assert_equal ["this", "  is", "  a", "  line"], @parser.send(:indent_from_line, "    My line", lines, 2, 5)
    #   lines = "this\n         is\n          a\n       line".split("\n")
    #   assert_equal ["this", "         is", "          a", "            line"], @parser.send(:indent_from_line, "    My line", lines, 2, 5)
    # end
  end

  context "A SLIM file in a project" do
    setup do
      @parser = Hammer::HAMLParser.new(:path => 'index.slim')
      def test(input, output)
        assert_equal output, @parser.parse(input)
      end
    end

    should "respond to to_format with :html and :slim" do
      @parser.parse('Hello, world!')
      assert_equal "Hello, world!", @parser.to_format(:html)
      assert_equal "Hello, world!", @parser.to_format(:html)
    end

    context "when parsing path tags" do
      setup do
        file = create_file('blog/index.slim', "<img src='<!-- @path logo.png -->' />", @parser.directory)
        logo = create_file('images/logo.png', "image", @parser.directory)
      end

      should "not replace HTML path tags" do
        assert_equal @parser.parse("<img src='<!-- @path logo.png -->' />"), "<img src='<!-- @path logo.png -->' />"
      end
    end

    # TODO test includes
    # context "with multiple-layer inheritance" do
    #   setup do
    #     @parser_directory = "tmp/#{rand(10000)}"
    #     `mkdir -p #{@parser_directory}`
    #     `mkdir -p #{@parser_directory}/partials`
    #     File.open("#{@parser_directory}/index.slim", 'w+') { |f| f.write '/! @include header' }
    #     File.open("#{@parser_directory}/partials/header.slim", 'w+') { |f| f.write 'header it is header' }
    #     
    #     def test(input, output)
    #       assert_equal output, @parser.parse(input)
    #     end
    #   end

    #   teardown do
    #     # `rm -rf #{@parser_directory}`
    #   end

    #   should "have the right output" do
    #     test File.open("#{@parser_directory}/index.slim").read, "<header>it is header</header>"
    #   end
    # end
  end
end
