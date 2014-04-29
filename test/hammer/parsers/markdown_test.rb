require "test_helper.rb"

class TestMarkdown < Test::Unit::TestCase
  context "An HTML file parser" do
    setup do
      @parser = Hammer::MarkdownParser.new :path => 'index.md'
    end

    should "parse markdown" do
      assert_equal "<h1>This is markdown</h1>", @parser.parse("# This is markdown")
    end

    should "preserve comments" do
      assert_equal "<!-- This is markdown -->", @parser.parse("<!-- This is markdown -->")
    end

    should "markdown includes" do
      input = "<!-- @include include -->"
      @parser.stubs(:find_file).returns(create_file 'include.md', 'Included', @parser.directory)
      @parser.parse(input)
      assert_equal input, @parser.to_format(:md)
      assert_equal @parser.parse(input), @parser.to_format(:html)
    end
  end
end
