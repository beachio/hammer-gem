require "test_helper"

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
      # TODO Write some path-testing HAML tests!
    end
    
  end
  
  context "A HAML file in a project" do
  
    setup do
      @parser = Hammer::HAMLParser.new(:path => "index.haml")
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
    
    ## Old stuff - deprecated.
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