require "test_helper"

module AssertCompilation
  def assert_compilation(pre, post)
    @parser.text = pre
    assert_equal post, @parser.parse()
  end
end

class CSSParserTest < Test::Unit::TestCase
  include AssertCompilation
  context "A CSS Parser" do
    setup do
      @options = {
        input_directory: Dir.mktmpdir,
        output_directory: Dir.mktmpdir,
        cache_directory: Dir.mktmpdir
      }
      # @hammer_project = Hammer::Project.new @options
      @parser = Hammer::CSSParser.new()
      @parser.stubs(:find_file).returns(nil)
      @parser.stubs(:find_files).returns([])

      @css_file = Hammer::HammerFile.new(filename: 'style.css')
      @parser.hammer_file = @css_file
    end

    def stub_out(file)
      @parser.stubs(:find_file).returns(file)
      @parser.stubs(:find_files).returns([file])
    end
    
    should "exist" do
      assert @parser
    end

    context "when parsing @import paths" do
      setup do
        @stylesheet = Hammer::HammerFile.new()
        @stylesheet.filename = "assets/imported.css"
        @parser.stubs(:find_file).returns(@stylesheet)
      end
      
      should "parse standard filenames" do
        @parser.text = '@import "imported.css"'
        assert_equal '@import "assets/imported.css";', @parser.parse()
      end

      should "not parse http links" do
        @parser.text = '@import "http://google.com/style.css"'
        assert_equal '@import "http://google.com/style.css"', @parser.parse()
      end
    end

    context "parsing clever paths" do
      setup do
        font = Hammer::HammerFile.new(filename: "images/proximanova-regular.eot")
        # @hammer_project << font
      
        @parser.stubs(:find_files).returns([font])
        @parser.stubs(:find_file).returns(font)
      end
      
      should "parse paths with normal comments" do
        @parser.text = "a { background: url(/* @path proximanova-regular.eot */) }"
        assert_equal "a { background: url(images/proximanova-regular.eot) }", @parser.parse()
      end
      
      should "parse paths on one line" do
        @parser.text = "a { background: url(/* @path proximanova-regular.eot */) }"
        assert_equal "a { background: url(images/proximanova-regular.eot) }", @parser.parse()
      end
      
      should "parse paths two to a line" do
        @parser.text = "a { background: url(/* @path proximanova-regular.eot */) url(/* @path proximanova-regular.eot */)}"
        assert_equal "a { background: url(images/proximanova-regular.eot) url(images/proximanova-regular.eot)}", @parser.parse()
      end
      
      should "parse paths with queries" do
        @parser.text = "a { background: url(proximanova-regular.eot?#iefix) }"
        assert_equal "a { background: url(images/proximanova-regular.eot?#iefix) }", @parser.parse()
      end
      
      should "parse URL images with queries that are just hashes" do
        @parser.text = "a { background: url(proximanova-regular.eot#iefix) }"
        assert_equal "a { background: url(images/proximanova-regular.eot#iefix) }", @parser.parse()
      end
      
      should "not parse css gradients" do
        @parser.text = "a { background: css-gradient(#dfdfdf,#f8f8f8); }"
        assert_equal "a { background: css-gradient(#dfdfdf,#f8f8f8); }", @parser.parse()
      end      
      
      should "not parse css gradients as includes" do
        @parser.text = "a/* @include css-gradient(#dfdfdf,#f8f8f8); */"
        assert_equal "a/* @include css-gradient(#dfdfdf,#f8f8f8); */", @parser.parse()
      end
      
      should "parse empty url()" do
        @parser.text = "a {background: url()}"
        assert_equal "a {background: url()}", @parser.parse()
      end
      
      should "parse multiple url() on one line" do
        image = Hammer::HammerFile.new
        image.filename = "button_bg_over.png"
        # @hammer_project << image
        @parser.stubs(:find_file).returns(image)
        @parser.text = ".aui-form-trigger:focus{background-image:url(button_bg_over.png)}.aui-trigger-selected{background: red}"
        output = ".aui-form-trigger:focus{background-image:url(button_bg_over.png)}.aui-trigger-selected{background: red}"
        assert_equal output, @parser.parse()
      end
    end

    
    context "with a CSS file" do
      
      setup do
        @file = Hammer::HammerFile.new
        @file.filename = "style.css"
        @parser.hammer_file = @file
        @file.raw_text = "a {background: red}"
      end
      
      should "parse CSS" do
        @parser.text = @file.raw_text
        assert_equal "a {background: red}", @parser.parse()
      end

      should "find scss files when including them" do
        @scss_file = Hammer::HammerFile.new :raw_text => "a { background: orange; }", :filename => "assets/_scss_include.scss"
        @parser.stubs(:find_file).returns(@scss_file)
        assert_compilation "url(_scss_include.css)", "url(assets/_scss_include.css)"
      end
      
      context "with other files" do

        setup do
          @asset_file = Hammer::HammerFile.new
          @asset_file.raw_text = "a { background: orange; }"
          @asset_file.filename = "assets/_include.css"
        end

        context "when only looking for this file" do
          setup do
            @parser.stubs(:find_file).returns(@asset_file)
          end
          should "replace the correct file correctly" do
            assert_compilation "url(_include.css)", "url(assets/_include.css)"
          end
          should "do include" do
            assert_compilation "/* @include _include */", "a { background: orange; }"
          end
          should "do paths" do
            assert_compilation "url(_include.css);", "url(assets/_include.css);"
          end
          should "do paths with normal comments" do
            assert_compilation "url(/* @path _include.css */);", "url(assets/_include.css);"
          end
          should "work with more than one url() on a line with or without a ;" do
            assert_compilation "url(../../_include.css)};url(_include.css)", "url(assets/_include.css)};url(assets/_include.css)"
            assert_compilation "url(/* @path ../../_include.css */)}url(_include.css)", "url(assets/_include.css)}url(assets/_include.css)"
            assert_compilation "url(../../_include.css)}url(/* @path _include.css */)", "url(assets/_include.css)}url(assets/_include.css)"
          end

          should "work with empty url()" do
            assert_compilation "url()", "url()"
          end

          should "do stupid relative paths again" do
            assert_compilation "url(../../_include.css);", "url(assets/_include.css);"
            assert_compilation "url(/* @path ../../_include.css */);", "url(assets/_include.css);"
          end

          should 'url(/* @path */)' do
            @parser.text = "url(/* @path assets/_include.css */);"
            assert_equal @parser.parse(), "url(assets/_include.css);"
            @parser.text = "url(/* @path assets/_include.css */);"
            assert_equal @parser.parse(), "url(assets/_include.css);"
          end

          should "match absolute file paths" do
            assert_compilation "url(/assets/_include.css);", "url(/assets/_include.css);"
          end

        end

    #     # should "do stupid relative paths" do
    #     #   # TODO: WHAT ? This shouldn't pass.
    #     #   # TODO: Make this more logical.
    #     #   assert_compilation "url(things/like/_include.css);", "url(assets/_include.css);"
    #     #   assert_compilation "url(/* @path things/like/_include.css */);", "url(assets/_include.css);"
    #     # end

        context "with multiple paths" do
          setup do
            @subfolder_file = Hammer::HammerFile.new
            @subfolder_file.filename = "something/assets/_include.css"
          end

          should "match files with matching file paths" do
            @parser.expects(:find_file).with('something/assets/_include.css').returns(@subfolder_file)
            assert_compilation "url(something/assets/_include.css);", "url(something/assets/_include.css);"
            @parser.expects(:find_file).with('ing/assets/_include.css').returns(@subfolder_file)
            assert_compilation "url(/* @path ing/assets/_include.css */);", "url(something/assets/_include.css);"
          end

        end

      end

      should "not do http paths" do
        assert_compilation "url(http://bullshit.png);", "url(http://bullshit.png);"          
      end

      should "not do https paths" do
        assert_compilation "url(https://bullshit.png);", "url(https://bullshit.png);"          
      end        

      should "not change query paths with unknown files" do
        assert_compilation "url(bullshit.png?a);", "url(bullshit.png?a);"          
      end
      
      should "do data:png paths" do
        assert_compilation "url(data:image/png;base64,123)", "url(data:image/png;base64,123)"
      end
      
    end
  end
end
