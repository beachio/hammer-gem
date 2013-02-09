require "./tests"

class CSSParserTest < Test::Unit::TestCase
  context "A CSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::CSSParser.new(@hammer_project)
    end
    
    should "exist" do
      assert @parser
    end
    
    context "with a CSS file" do
      
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "style.css"
      end
      
      should "parse CSS" do
        @file.raw_text = "a {background: red}"
        
        assert_equal @file.parser, @parser.class
        @parser.hammer_file = @file
        @parser.text = @file.text
        
        result = @parser.parse()
        assert_equal @file.text, result
      end
      
      context "with other files" do
        
        setup do
          @new_file = Hammer::HammerFile.new
          @new_file.raw_text = "I'm included."
          @new_file.filename = "_include.css"
          @hammer_project << @new_file 
        end
        
        should "do include" do
          @parser.text =  "/* @include _include */"
          output = @parser.parse()
          assert_equal @hammer_project.find_file("_include", 'css'), @new_file
          assert output
          assert_equal "I'm included.", output
        end
      end
      
    end
  end
end

