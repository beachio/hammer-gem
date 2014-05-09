require "test_helper"
require "hammer/parser"
require "hammer/parsers/css"

class CSSParserTest < Test::Unit::TestCase

  context "A CSS Parser" do
    setup do
      @parser = Hammer::CSSParser.new(:path => "style.css")

      def test(input, output)
        assert_equal output, @parser.parse(input)
      end

      def stub_out(file)
        @parser.stubs(:find_files).returns([file])
      end
    end

    context "when parsing @import paths" do
      setup do
        file = create_file('assets/imported.css', "a { background: red; }", @parser.directory)
        stub_out file
      end

      should "parse standard filenames or HTTP links" do
        assert_equal '@import "assets/imported.css";', @parser.parse('@import "imported.css"')
        assert_equal '@import "http://google.com/style.css"', @parser.parse('@import "http://google.com/style.css"')
      end
    end

    context "with no other files" do
      setup do
        @parser.stubs(:find_files).returns([])
      end
      should "not replace @path or @import tags" do
        test "/* @path abc */", "/* @path abc */"
        test '/* @import "abc" */', '/* @import "abc" */'
      end
      should "not replace @import tags that start with http" do
        test '/* @import "http://abc.com/" */', '/* @import "http://abc.com/" */'
      end
    end

    context "parsing clever paths" do
      setup do
        font = create_file('images/proximanova-regular.eot', 'x', @parser.directory)
        @parser.stubs(:find_files).returns([font])
      end

      should "parse paths with normal comments" do
        test "a { background: url(/* @path proximanova-regular.eot */) }", "a { background: url(images/proximanova-regular.eot) }"
      end

      should "parse paths on one line" do
        test "a { background: url(/* @path proximanova-regular.eot */) }", "a { background: url(images/proximanova-regular.eot) }"
      end

      should "parse paths two to a line" do
        test "a { background: url(/* @path proximanova-regular.eot */) url(/* @path proximanova-regular.eot */)}", "a { background: url(images/proximanova-regular.eot) url(images/proximanova-regular.eot)}"
      end

      should "parse paths with queries" do
        test "a { background: url(proximanova-regular.eot?#iefix) }", "a { background: url(images/proximanova-regular.eot?#iefix) }"
      end

      should "parse URL images with queries that are just hashes" do
        test "a { background: url(proximanova-regular.eot#iefix) }", "a { background: url(images/proximanova-regular.eot#iefix) }"
      end

      should "not parse css gradients" do
        test "a { background: css-gradient(#dfdfdf,#f8f8f8); }", "a { background: css-gradient(#dfdfdf,#f8f8f8); }"
      end

      should "not parse css gradients as includes" do
        test "/* @include css-gradient(#dfdfdf,#f8f8f8); */", "/* @include css-gradient(#dfdfdf,#f8f8f8); */"
      end

      should "parse empty url()" do
        test "a {background: url()}", "a {background: url()}"
      end

      should "parse multiple url() on one line" do
        image = create_file("button_bg_over.png", "nothing", @parser.directory)
        @parser.stubs(:find_files).returns([image])
        test ".aui-form-trigger:focus{background-image:url(button_bg_over.png)}.aui-trigger-selected{background: red}", ".aui-form-trigger:focus{background-image:url(button_bg_over.png)}.aui-trigger-selected{background: red}"
      end
    end


    context "with a CSS file" do
      setup do
        @file = create_file('style.css', 'a {background: red}', @parser.directory)
      end

      should "parse CSS" do
        test "a {background: red}", @parser.parse("a {background: red}")
      end

      should "find scss files when including them" do
        # scss_file = create_file "assets/scss_include.scss", "a { background: orange; }", @parser.directory
        stub_out "assets/scss_include.css"
        test "url(scss_include.css)", "url(assets/scss_include.css)"
      end

      context "with other files" do

        setup do
          @asset_file = create_file('assets/_include.css', 'a { background: orange; }', @parser.directory)
        end

        context "when only looking for this file" do
          setup do
            stub_out @asset_file
          end

          should "replace the correct file correctly" do
            test "url(_include.css)", "url(assets/_include.css)"
          end

          should "do include" do
            test "/* @include _include */", "a { background: orange; }"
          end

          should "do paths" do
            test "url(_include.css);", "url(assets/_include.css);"
          end

          should "do paths with normal comments" do
            test "url(/* @path _include.css */);", "url(assets/_include.css);"
          end

          should "work with more than one url() on a line with or without a ;" do
            test "url(../../_include.css)};url(_include.css)", "url(assets/_include.css)};url(assets/_include.css)"
            test "url(/* @path ../../_include.css */)}url(_include.css)", "url(assets/_include.css)}url(assets/_include.css)"
            test "url(../../_include.css)}url(/* @path _include.css */)", "url(assets/_include.css)}url(assets/_include.css)"
          end

          should "work with empty url()" do
            test "url()", "url()"
          end

          should "do stupid relative paths again" do
            test "url(../../_include.css);", "url(assets/_include.css);"
            test "url(/* @path ../../_include.css */);", "url(assets/_include.css);"
          end

          should 'url(/* @path */)' do
            test "url(/* @path assets/_include.css */);", "url(assets/_include.css);"
          end

          should "match absolute file paths" do
            test "url(/assets/_include.css);", "url(/assets/_include.css);"
          end

        end

        context "with multiple paths" do
          setup do
            @file = create_file("something/assets/_include.css", "text", @parser.directory)
          end

          should "match files with matching file paths" do
            @parser.expects(:find_files).with('something/assets/_include.css', nil).returns([@file]).at_least_once
            test "url(something/assets/_include.css);", "url(something/assets/_include.css);"
            @parser.expects(:find_files).with('ing/assets/_include.css', nil).returns([@file]).at_least_once
            test "url(/* @path ing/assets/_include.css */);", "url(something/assets/_include.css);"
          end
        end
      end

      should "not do http paths" do
        test "url(http://bullshit.png);", "url(http://bullshit.png);"
        test "@import http://google.com", "@import http://google.com"
        test "/* @path http://google.com */", "/* @path http://google.com */"
        test "url(https://bullshit.png);", "url(https://bullshit.png);"
      end

      should "not change query paths with unknown files" do
        @parser.stubs(:find_files).returns([])
        test "url(bullshit.png?a);", "url(bullshit.png?a);"
      end

      should "do data:png paths" do
        test "url(data:image/png;base64,123)", "url(data:image/png;base64,123)"
      end

    end
  end
end

# should "do stupid relative paths" do
#   # TODO: WHAT ? This shouldn't pass.
#   # TODO: Make this more logical.
#   assert_compilation "url(things/like/_include.css);", "url(assets/_include.css);"
#   assert_compilation "url(/* @path things/like/_include.css */);", "url(assets/_include.css);"
# end