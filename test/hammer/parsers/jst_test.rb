require File.join File.dirname(__FILE__), "test_helper"
require 'hammer/parser'
require 'hammer/parsers/jst'

class JSTParserTest < Test::Unit::TestCase
  # include AssertCompilation
  context "A JST Parser" do
    setup do
      @parser = Hammer::JSTParser.new(:path => 'app.js')
      @parser.parse("<span><%= title %></span>")
    end

    def stub_out(file)
      @parser.stubs(:find_file).returns(file)
      @parser.stubs(:find_files).returns([file])
    end

    should "return JS for to_format with :js" do
      assert @parser.to_format(:js).include? "<span>"
      assert @parser.to_format(:js).include? "window.JST[\"app\"]"
    end
  end
end
