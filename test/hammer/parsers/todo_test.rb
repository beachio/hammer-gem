require File.join(File.dirname(__FILE__), "test_helper.rb")
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
  end
end