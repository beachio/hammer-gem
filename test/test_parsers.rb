require "tests"

class TestParsers < Test::Unit::TestCase
  
  context "a parser" do
    setup do
      @project = Hammer::Project.new
      
      @file = Hammer::HammerFile.new
      @file.filename = "blog/index.html"
      @project << @file

      @parser = Hammer::HammerParser.new
      @parser.hammer_project = @project
      @parser.hammer_file = @file
      
      @logo = Hammer::HammerFile.new
      @logo.filename = "blog/logo.png"
      @project << @logo
      
      @haml = Hammer::HammerFile.new
      @haml.filename = "/blog/_haml.haml"
      @project << @haml
    end
    
    should "find files with ./" do
      assert_equal @logo, @parser.find_file("logo.png")
      assert_equal @logo, @parser.find_file("./logo.png")
      assert_equal @haml, @parser.find_file("_haml", "html")
    end
    
  end
  
  context "where there's an error in an include" do
    setup do
      @project = Hammer::Project.new
      
      @file = Hammer::HammerFile.new
      @file.filename = "index.html"
      @file.raw_text = "The header: <!-- @include _header --> great"
      @project << @file
      
      @header = Hammer::HammerFile.new
      @header.filename = "_header.html"
      @header.raw_text = "a <!-- $title --> a"
      @project << @header
      
      @parser = Hammer.parser_for_hammer_file(@file)
      @parser.hammer_project = @project
      @parser.text = @file.raw_text
    end
    
    should "raise an error" do
      assert_raises Hammer::Error do
        text = @parser.parse()
      end
    end
    
    should "set error_file on the file" do
      begin
        @parser.parse()
      rescue Hammer::Error => e
        assert e
        assert_equal @header, e.hammer_file
      end
    end
  end
  
  
end