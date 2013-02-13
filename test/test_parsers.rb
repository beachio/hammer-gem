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
  
  
end