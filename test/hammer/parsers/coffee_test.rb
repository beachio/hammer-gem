# require File.join File.dirname(__FILE__), "test_helper"
# require 'coffee-script'

# class CoffeeParserTest < Test::Unit::TestCase
#   include AssertCompilation
#   context "A Coffee Parser" do
#     setup do
#       @options = {
#         :input_directory => Dir.mktmpdir,
#         :output_directory => Dir.mktmpdir,
#         :cache_directory => Dir.mktmpdir
#       }
#       @parser = Hammer::CoffeeParser.new()
#       @parser.stubs(:find_file).returns(nil)
#       @parser.stubs(:find_files).returns([])

#       @js_file = Hammer::HammerFile.new(:filename => 'app.coffee', :text => "a = -> 'b'")
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
#     end

#     should "return JS for to_format with :coffee" do
#       assert_equal @parser.to_format(:coffee), @parser.text
#     end

#     should "do includes" do
#       @parser.parse()
#     end

#     should "Raise an error with bad Coffee" do
#       @parser.text = "a = function(){};"
#       assert_raises Hammer::Error do
#         @parser.parse
#       end
#       assert @parser.hammer_file.error.is_a? Hammer::Error
#       assert @parser.hammer_file.error.message.include? "Coffeescript Error"
#       assert @parser.hammer_file.error.message.include? "function"
#     end

#     should "include" do
#       @parser.text = "# @include other"
#       file = Hammer::HammerFile.new(:filename => "other.js", :raw_text => "alert('a')")
#       @parser.stubs(:find_file).returns(file)
#       @parser.stubs(:find_files).returns([file])
#       text = @parser.parse()
#       assert text.include? "/* @include other */"
#     end
#   end
# end
