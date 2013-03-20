require "tests"

class HammerAppTemplateTest < Test::Unit::TestCase
  
  context "A template" do
    setup do
      file = Hammer::HammerFile.new(:filename => "index.html")
      file.full_path = "/Users/elliott/index.html"
      @template = Hammer::AppTemplate.new([file], Hammer::Project.new)
    end
    
    should "compile" do
      assert @template.to_s
      assert @template.to_s.length > 0
    end
  end
  
  ['_header.html', 'index.html'].each do |filename|
    context "A template called #{filename} with a todo" do
      setup do
        file = Hammer::HammerFile.new(:filename => filename)
        file.messages = [{:line => 1, :message => "Testing", :html_class => "todo"}]
        @template = Hammer::AppTemplate.new([file], Hammer::Project.new)
      end
      
      should "show the todo" do
        assert @template.to_s.include? 'Testing'
      end
    end
  end
  
  context "A template with files" do
    setup do
      @file = Hammer::HammerFile.new(:filename => "index.html")
      @file.compiled = true
      @file.full_path = "/Users/elliott/home files\"/index.html"
      @template = Hammer::AppTemplate.new([@file], Hammer::Project.new)
      @text = @template.to_s
    end
    
    should "have a first line" do
      assert_equal @text.split("\n")[0], "1 HTML file"
    end
    
    should "display the right output" do
      assert @text.include? "/Users/elliott/home files&quot;/index.html"
      assert @text.include? "Built"
    end
    
    context "with errors" do
      setup do
        @file.expects(:error).at_least_once.returns(Hammer::Error.new("Error message", 123))
        @text = @template.to_s
      end
      
      should "display the error messages" do
        assert @text.include? "Error message"
        assert @text.include? "123"
      end
    end
  end
  
  context "A template with files including a partial" do
    setup do
      files = []
      @file = Hammer::HammerFile.new(:filename => "index.html")
      @file.full_path = "/Users/elliott/home files\"/index.html"
      files << @file
      
      @file = Hammer::HammerFile.new(:filename => "_nav.html")
      @file.full_path = "/Users/elliott/home files\"/_nav.html"
      files << @file
      
      @template = Hammer::AppTemplate.new(files, Hammer::Project.new)
    end
    
    should "Not display the partials" do
      assert !@template.to_s.include?("_nav.html")
    end
  end

  
end