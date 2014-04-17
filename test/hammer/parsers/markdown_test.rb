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
    
    # context "with a hammer file" do
    #   should "set variables" do
      
    #   end
    # end
    
  end
end
