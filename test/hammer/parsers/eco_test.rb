# require File.join File.dirname(__FILE__), "test_helper"
# require 'hammer/parsers/jst'

# class EcoParserTest < Test::Unit::TestCase
#   include AssertCompilation
#   context "An Eco Parser" do
#     setup do
#       @options = {
#         :input_directory => Dir.mktmpdir,
#         :output_directory => Dir.mktmpdir,
#         :cache_directory => Dir.mktmpdir
#       }
#       @parser = Hammer::EcoParser.new()
#       @parser.stubs(:find_file).returns(nil)
#       @parser.stubs(:find_files).returns([])

#       @js_file = Hammer::HammerFile.new(:filename => 'app.eco', :text => "<span><%= title %></span>")
#       @parser.hammer_file = @js_file
#       @parser.text = @js_file.raw_text
#     end

#     def stub_out(file)
#       @parser.stubs(:find_file).returns(file)
#       @parser.stubs(:find_files).returns([file])
#     end
    
#     should "exist" do
#       assert @parser
#     end

#     should "return JS for to_format with :js" do
#       assert_equal @parser.to_format(:js), @parser.text
#       assert @parser.to_format(:js).include? "<span>"
#       assert @parser.to_format(:js).include? "window.JST[\"app\"]"
#     end
#   end
# end
