require 'test_helper'
require 'hammer/parsers/jst'

class EcoParserTest < Test::Unit::TestCase
  context "An Eco Parser" do
    setup do
      @parser = Hammer::EcoParser.new(:path => 'app.eco')
      @parser.stubs(:find_files).returns([])
      @js_file = create_file 'app.eco', '<span><%= title %></span>', @parser.directory
    end

    def stub_out(file)
      @parser.stubs(:find_file).returns(file)
      @parser.stubs(:find_files).returns([file])
    end
    
    should "exist" do
      assert @parser
    end

    should "return JS for to_format with :js" do
      @parser.parse('<span><%= title %></span>')
      assert_equal @parser.to_format(:js), @parser.text
      assert @parser.to_format(:js).include? "<span>"
      assert @parser.to_format(:js).include? "window.JST[\"app\"]"
    end
  end
end