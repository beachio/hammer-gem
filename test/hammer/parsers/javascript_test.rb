# require "test_helper"

# class JSParserTest < Test::Unit::TestCase
#   include AssertCompilation
#   context "A JS Parser" do
#     setup do
#       @options = {
#         :input_directory => Dir.mktmpdir,
#         :output_directory => Dir.mktmpdir,
#         :cache_directory => Dir.mktmpdir
#       }
#       # @hammer_project = Hammer::Project.new @options
#       @parser = Hammer::JSParser.new()
#       @parser.stubs(:find_file).returns(nil)
#       @parser.stubs(:find_files).returns([])

#       @js_file = Hammer::HammerFile.new(:filename => 'app.js')
#       @parser.hammer_file = @js_file
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

#     context "with a CSS file" do
      
#       setup do
#         @file = Hammer::HammerFile.new
#         @file.filename = "style.js"
#         @parser.hammer_file = @file
#         @file.raw_text = "a {background: red}"
#       end
      
#       should "parse JS" do
#         @parser.text = @file.raw_text
#         assert_equal "a {background: red}", @parser.parse()
#       end
      
#       context "with other files" do
#         setup do
#           @asset_file = Hammer::HammerFile.new
#           @asset_file.raw_text = "a { background: orange; }"
#           @asset_file.filename = "assets/_include.js"
#         end

#         context "when only looking for this file" do
#           setup do
#             @parser.stubs(:find_file).returns(@asset_file)
#           end

#           should "do include" do
#             assert_compilation "/* @include _include */", "a { background: orange; }"
#           end
#         end
#       end
#     end
#   end
# end
