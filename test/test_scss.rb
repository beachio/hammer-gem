require "./tests.rb"

class TestSCSS < Test::Unit::TestCase
  context "A SCSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::SASSParser.new
    end
    should "parse SASS" do
      # @parser.format = :scss
      @hammer_file = Hammer::HammerFile.new
      @hammer_file.filename = "style.scss"
      @parser.hammer_file = @hammer_file
      
      # @parser.filename = "style.scss"
      @parser.text = "a { b { background: red; } }"
      assert_equal "a b {\n  background: red; }\n", @parser.parse()
    end
    
    
    context "with other SCSS files" do
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "style.scss"
        @file.raw_text = "a { background: red; }"
        @hammer_project << @file
      end
      
      should "include SCSS files" do
        @hammer_project.expects(:find_files).returns([@file])
        new_file = Hammer::HammerFile.new(:text => "/* @include style */", :filename => "whatever.scss", :hammer_project => @hammer_project)
                
        parser = Hammer::SASSParser.new(@hammer_project)
        parser.text = new_file.raw_text
        parser.hammer_file = new_file
        
        text = parser.parse()
        assert_equal "a {\n  background: red; }\n", text
      end
    end
    
    
  end
  
end