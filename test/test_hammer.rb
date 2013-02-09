require "./tests"

class HammerTest < Test::Unit::TestCase
  context "Hammer"  do
    should "find the right parser" do
      assert_equal Hammer.parser_for("html"), Hammer::HTMLParser
    end
  end
end