class TestJavascriptTemplates < Test::Unit::TestCase
  
  context "A JST Parser" do
    setup do
      @parser = Hammer::JSTParser.new
      @hammer_file = Hammer::HammerFile.new
      @hammer_file.filename = "header.jst"
      @parser.hammer_file = @hammer_file
    end

    should "be the default for .jst files" do
      assert_equal Hammer.parsers_for_extension("jst")[0], Hammer::JSTParser
      assert_equal Hammer::JSTParser, Hammer.parser_for_hammer_file(@hammer_file).class
    end

    should "false" do
      @parser.text = "<h1></h1>"
      assert @parser.parse().include? "window.JST[\"header\"]"
    end
  end

end