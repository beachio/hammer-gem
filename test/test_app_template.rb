require "./tests"

class HammerAppTemplateTest < Test::Unit::TestCase
  
  context "A template" do
    setup do
      file = Hammer::HammerFile.new(:filename => "index.html")
      file.full_path = "/Users/elliott/index.html"
      @template = Hammer::AppTemplate.new([file])
    end
    
    should "compile" do
      assert @template.to_s
      assert @template.to_s.length > 0
    end
  end
  
  context "A template with files" do
    setup do
      files = []
      @file = Hammer::HammerFile.new(:filename => "index.html")
      @file.error_message = "Error message"
      @file.error_line = 123
      @file.full_path = "/Users/elliott/home files\"/index.html"
      files << @file
      @template = Hammer::AppTemplate.new(files)
    end
    
    should "Display the right output" do
      text = @template.to_s
      
      puts text
      
      [
        "Error message",
        "/Users/elliott/home files&quot;/index.html",
        "123"
      ].each do |line|
        assert text.include? line
      end
      
    end
  end
end