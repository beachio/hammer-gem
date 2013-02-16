require "tests"

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
        @parser.hammer_file = @file
        @file.raw_text = "a {background: red}"
      end
      
      should "parse CSS" do
        @parser.text = @file.raw_text
        assert_equal @file.raw_text, @parser.parse()
      end
      
      context "with other files" do
        
        setup do
          @new_file = Hammer::HammerFile.new
          @new_file.raw_text = "I'm included."
          @new_file.filename = "assets/_include.css"
          @hammer_project << @new_file
        end
        
        should "do paths" do
          @parser.text = "url(_include.css);"
          assert output = @parser.parse()
          assert_equal output, "url(assets/_include.css);"
        end
        
        should "do data:png paths" do
          @parser.text = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAooAAAAZCAYAAAC2GQ9IAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAF4BJREFUeNrsXQlYFFe2LpoGgQZtVEARjYrigijuW9xIHNQxLsm4PWNERxhw17glE2OIz2U0xnFl1JeYoFGzqdHEMUHFLcaFuCBk3CKIyoAoNFtAoOn5T3sbO"
          assert output = @parser.parse()
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
  
  context "A SCSS parser" do
    setup do
      @hammer_project = Hammer::Project.new
    end
    
    context "with an SCSS file that has an include of a CSS file" do
      setup do
        @parser = Hammer::SASSParser.new(@hammer_project)
        @file = Hammer::HammerFile.new
        @file.filename = "style.scss"
        @file.raw_text = "/* @include normalize */"
        @parser.hammer_file = @file
        @hammer_project << @file
        file = Hammer::HammerFile.new
        file.filename = "normalize.css"
        file.raw_text = "* {normalize: true}"
        @hammer_project << file
      end
      
      should "Be able to include the normalize" do
        assert_equal "* {\n  normalize: true; }\n", @parser.parse()
      end
    end
  end
end