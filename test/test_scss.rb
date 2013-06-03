require "tests.rb"

class TestSCSS < Test::Unit::TestCase
  
    def assert_includes(a, b)
      assert a.include? b
    end
  
  context "A SCSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::SASSParser.new
    end
    
    should "parse SASS" do
      @hammer_file = Hammer::HammerFile.new
      @hammer_file.filename = "style.scss"
      @parser.hammer_file = @hammer_file
      @parser.hammer_project = @hammer_project
      
      @parser.text = "a { b { background: red; } }"
      assert_includes @parser.parse(), "a b {\n  background: red; }\n"
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
        parser.text = "/* @include style */"
        parser.hammer_file = new_file
        
        text = parser.parse()
        assert_includes text, "a {\n  background: red; }\n"
      end
    end
    
    
  end
  
  
  context "A SCSS parser" do
    setup do
      @hammer_project = Hammer::Project.new
    end
    
    context "with an SCSS file" do
      
      setup do
        @parser = Hammer::SASSParser.new(@hammer_project)
        @file = Hammer::HammerFile.new()
        @parser.hammer_file = Hammer::HammerFile.new()
        @parser.hammer_file.filename = "style.scss"
        @parser.text = "/* @include normalize */"
      end
      
      context "that has an include of a CSS file" do
        setup do
          file = Hammer::HammerFile.new
          file.filename = "normalize.css"
          file.raw_text = "* {normalize: true}"
          @hammer_project << file
        end
      
        should "Be able to include the normalize" do
          assert_equal "/* @include normalize */\n", @parser.parse()
        end
      end      
      
      # context "that has an include of a SASS file" do
      #   setup do
      #     file = Hammer::HammerFile.new
      #     file.filename = "normalize.sass"
      #     file.raw_text = "* \n  normalize: true"
      #     @hammer_project << file
      #   end
      
      #   should "Be able to include the normalize" do
      #     assert_equal "/* @include normalize */\n", @parser.parse()
      #   end
      # end
      
      
      
    end
  end
  
end