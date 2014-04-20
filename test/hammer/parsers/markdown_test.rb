require "test_helper.rb"

class TestMarkdown < Test::Unit::TestCase
  context "An HTML file parser" do
    setup do
      @parser = Hammer::MarkdownParser.new
    end
    
    should "parse markdown" do
      assert_equal @parser.parse("# This is markdown"), "<h1>This is markdown</h1>"
    end
    
    should "preserve comments" do
      assert_equal @parser.parse("<!-- This is markdown -->"),  "<!-- This is markdown -->"
    end

    should "markdown includes" do
      input = "<!-- @include include -->"
      @parser.parse(input)
      assert_equal input, @parser.to_format(:md)
      assert_equal @parser.parse(input), @parser.to_format(:html)
    end
  end
end
