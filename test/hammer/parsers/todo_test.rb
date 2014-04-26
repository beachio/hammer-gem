require 'hammer/test_helper'
require 'hammer/parsers/todos'

class TestTodoParser < Test::Unit::TestCase
  context "A Todo parser" do
    should "parse html todos" do
      @parser = Hammer::TodoParser.new :path => "index.html"
      @parser.parse("<!-- @todo This -->")
      assert_equal({1 => ["This"]}, @parser.todos)
    end

    should "parse coffee todos" do
      @parser = Hammer::TodoParser.new :path => "index.coffee"
      @parser.parse("# @todo This")
      assert_equal({1 => ["This"]}, @parser.todos)
    end

    should "give the right regex" do
      {
        'index.html' => Hammer::TodoParser::HTML_REGEX,
        'index.css' => Hammer::TodoParser::CSS_REGEX,
        'index.scss' => Hammer::TodoParser::SCSS_SASS_REGEX,
        'index.sass' => Hammer::TodoParser::SCSS_SASS_REGEX,
        'index.jst' => Hammer::TodoParser::JST_JS_REGEX,
        'index.js' => Hammer::TodoParser::JST_JS_REGEX
      }.each do |path, regex|
        @parser = Hammer::TodoParser.new :path => path
        assert_equal @parser.regex, regex
      end

    end
  end
end