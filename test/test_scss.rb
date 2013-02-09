require "./tests.rb"
class SCSSParserTest < Test::Unit::TestCase
  context "A SCSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::SASSParser.new
    end
    should "parse SASS" do
      @parser.format = :scss
      @parser.text = "a { b { background: red; } }"
      assert_equal "a b {\n  background: red; }\n", @parser.parse()
    end
  end
end