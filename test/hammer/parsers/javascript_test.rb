require "test_helper"

class JSParserTest < Test::Unit::TestCase
#   include AssertCompilation
  context "A JS Parser" do
    setup do
      @parser = Hammer::JSParser.new()
      @parser.stubs(:find_files).returns([])
      @js_file = create_file('app.js', 'testing', @parser.directory)
    end

    def stub_out(file)
      @parser.stubs(:find_files).returns([file])
    end
    
    should "return JS for to_format with :js" do
      assert_equal @parser.to_format(:js), @parser.text
    end

    context "with a CSS file" do
      
      setup do
        @file = create_file('style.js', 'var a = function(argument){return true}', @parser.directory)
      end
      
      should "parse JS" do
        assert_equal 'var a = function(argument){return true}', @parser.parse('var a = function(argument){return true}')
      end
      
      context "with other files" do
        setup do
          @asset_file = create_file "assets/_include.js", "a { background: orange; }", @parser.directory
        end

        context "when only looking for this file" do
          setup do
            @parser.stubs(:find_files).returns([@asset_file])
          end

          should "do include" do
            assert @parser.parse("/* @include _include */").include? "background: orange"
          end
        end
      end
    end
  end
end
