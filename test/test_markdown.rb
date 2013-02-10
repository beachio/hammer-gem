require "./tests.rb"

class TestMarkdown < Test::Unit::TestCase
  context "An HTML file parser" do
    setup do
      @parser               = Hammer::MarkdownParser.new
    end
    
    should "parse markdown" do
      @parser.text = "# This is markdown"
      assert_equal "<h1 id=\"this-is-markdown\">This is markdown</h1>\n", @parser.parse()
    end
    
    should "preserve comments" do
      @parser.text = "<!-- This is markdown -->"
      assert_equal "<!-- This is markdown -->\n", @parser.parse()
    end
    
    context "with a hammer file" do
      should "set variables" do
      
      end
    end
    
  end
end
