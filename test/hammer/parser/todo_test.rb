require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'hammer/parsers/todos'

class TestTodoParser < Test::Unit::TestCase
  context "A Todo parser" do
    context "html" do
      setup do
        @file = Hammer::HammerFile.new(:filename => "index.html", :text => "<!-- @todo This -->")
        @parser = Hammer::TodoParser.new :hammer_file => @file
      end

      should "have the right regex for HTML" do
        assert_equal @parser.regex, Hammer::TodoParser::HTML_REGEX
      end

      should "parse todos" do
        todos = @parser.parse()
        assert_equal todos, {1 => ["This"]}
      end
    end

    context "coffee" do
      setup do
        @file = Hammer::HammerFile.new(:filename => "index.coffee", :text => "# @todo This")
        @parser = Hammer::TodoParser.new :hammer_file => @file
      end

      should "have the right regex for HTML" do
        assert_equal @parser.regex, Hammer::TodoParser::COFFEE_REGEX
      end

      should "parse todos" do
        todos = @parser.parse()
        assert_equal todos, {1 => ["This"]}
      end
    end
  end
end
