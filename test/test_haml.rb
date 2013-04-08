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
    # end
    
    # context "with multiple-layer inheritance" do
      
    #   setup do
    #     @parser = Hammer::HTMLParser.new(@hammer_project)
    #     @file = Hammer::HammerFile.new(:filename => "index.haml", :hammer_project => @hammer_project)
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
    #   end
      
    #   should "have the right output" do
    #     @parser.hammer_file = @file
    #     text = @parser.parse()
    #     assert_equal "Second level included!", text
    #   end
      
    # end
    
    
    
  end
  
end
