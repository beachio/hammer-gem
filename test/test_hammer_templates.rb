require "tests"

class TestJavascriptTemplates < Test::Unit::TestCase
  
  context "A JST Parser" do
    setup do
      @parser = Hammer::JSTParser.new
      @hammer_file = Hammer::HammerFile.new
      @hammer_file.filename = "header.js"
      @parser.hammer_file = @hammer_file
    end

    should "false" do
      @parser.text = "<h1></h1>"
      assert @parser.parse().include? "window.JST[\"header\"]"
    end
  end

end