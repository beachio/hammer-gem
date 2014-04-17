require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'hammer/parsers/todos'

class TestTodoParser < Test::Unit::TestCase
  context "A Todo parser" do
    should "parse html todos" do
      @parser = Hammer::TodoParser.new :path => "index.html"
      assert_equal({1 => ["This"]}, @parser.parse("<!-- @todo This -->"))
    end

    should "parse coffee todos" do
      @parser = Hammer::TodoParser.new :path => "index.coffee"
      assert_equal({1 => ["This"]}, @parser.parse("# @todo This"))
    end
  end
end