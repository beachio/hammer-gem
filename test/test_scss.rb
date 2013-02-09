require "./tests.rb"

class TestSCSS < Test::Unit::TestCase
  context "A SCSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::SASSParser.new
    end
    should "parse SASS" do
      @parser.format = :scss
      @parser.text = "a { b { background: red; } }"
      assert_equal "a b {\n  background: red; }\n", @parser.parse()
    end
    
    
    context "with other CSS files" do
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "style.css"
        @file.raw_text = "a { background: red; }"
        @hammer_project << @file
      end
      
      should "include CSS files" do
        @hammer_project.expects(:find_file).returns(@file)
        new_file = Hammer::HammerFile.new
        new_file.filename = "whatever.css"
        new_file.raw_text = "/* @include style */"
        
        parser = new_file.parser.new(@hammer_project)
        parser.hammer_file = new_file
        
        text = parser.parse()
        assert_equal "a { background: red; }", text
      end
    end
    
    
  end
  
end