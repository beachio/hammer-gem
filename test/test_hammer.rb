require "./tests"

class TestHammer < Test::Unit::TestCase
  context "Hammer"  do
    should "find the right parser" do
      assert_equal Hammer.parser_for("html"), Hammer::HTMLParser
    end
    should "match filenames" do
      assert "index.html".match     Hammer.regex_for("index", ["html"])
      assert "about.html".match     Hammer.regex_for("*", ["html"])
      assert "assets/app.js".match  Hammer.regex_for("/*", ["js"])
      assert "assets/app.js".match  Hammer.regex_for("/assets/*", ["js"])
      assert "assets/app.js".match  Hammer.regex_for("assets/*", ["js"])
    end
  end
  
end