require "./tests"

class TestHammer < Test::Unit::TestCase
  context "Hammer"  do
    should "find the right parser" do
      assert_equal Hammer.parser_for("html"), Hammer::HTMLParser
    end
    
    should "perform clever path matching" do
      assert "index.html".match     Hammer.regex_for("index", ["html"])
      assert "about.html".match     Hammer.regex_for("*", ["html"])
      assert "assets/app.js".match  Hammer.regex_for("/*", ["js"])
      assert "assets/app.js".match  Hammer.regex_for("/assets/*", ["js"])
      assert "assets/app.js".match  Hammer.regex_for("assets/*", ["js"])
      
      def match(filename, tag, extensions=[])
        filename.match Hammer.regex_for(tag, [*extensions])
      end
      assert match "index.html", "/index", ["html"]

      assert match "index.html", "index", ["html"]
      assert match "index.html", "*", ["html"]
      assert match "assets/javascript.js", "*", ["js"]
      assert match "assets/javascript.js", "assets/*", ["js"]
      assert match "index.html", "/index", ["html"]
      assert match "index.html", "/index", ["html"]
      assert match "index.html", "/*", ["html"]
      assert match "assets/_header.html", "_header", ["html"]
      assert match "logo.png", "logo.png"
      assert match "assets/style.scss", "style", ['css', 'scss']

      assert !match("index.html", "*", ["js"])
      assert !match("/assets/index.html", "*", ["css"])
    end
  end
  
end