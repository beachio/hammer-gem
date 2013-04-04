require "tests"

class TestHaml < Test::Unit::TestCase
  context "A HAML file parser" do
    setup do
      @parser = Hammer::HAMLParser.new
    end
    
    should "parse haml" do
      @parser.text = "#hello Hi"
      assert_equal "<div id='hello'>Hi</div>\n", @parser.parse()
    end
    
    should "preserve comments" do
      @parser.text = "/ @include _header"
      assert_equal "<!-- @include _header -->\n", @parser.parse()
    end

    should "paths" do
      @parser.text = "/ @include _header"
      assert_equal "<!-- @include _header -->\n", @parser.parse()
    end
    
  end
  context "A HAML file in a project" do
  
    setup do
      @hammer_project       = Hammer::Project.new
      @file                 = Hammer::HammerFile.new(:hammer_project => @hammer_project, :filename => "index.haml")
      @parser               = Hammer::HAMLParser.new(@hammer_project)
    end
    
    context "when parsing path tags" do
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "blog/index.haml"
        @file.raw_text = "<img src='<!-- @path logo.png -->' />"
        logo = Hammer::HammerFile.new
        logo.filename = "images/logo.png"
        @hammer_project << logo
      end
      
      should "not replace HTML path tags" do
        @parser.hammer_file = @file
        text = @parser.parse()
        assert_equal "<img src='<!-- @path logo.png -->' />\n", text
      end
    end
  end
end
