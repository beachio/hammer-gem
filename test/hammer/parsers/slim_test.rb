require 'hammer/test_helper'
require 'hammer/parser'
require 'hammer/parsers/slim'

class SlimParserTest < Test::Unit::TestCase
  # include AssertCompilation
  context "A Slim Parser" do
    setup do
      @parser = Hammer::SlimParser.new(:path => 'app.js')
    end

    should "return JS for to_format with :js" do
      assert_equal @parser.parse("h1 This is my text"), "<h1>This is my text</h1>"
    end
  end
end
