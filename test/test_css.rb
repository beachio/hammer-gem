class CSSParserTest < Test::Unit::TestCase
  context "A CSS Parser" do
    setup do
      @hammer_project = Hammer::Project.new
      @parser = Hammer::CSSParser.new(@hammer_project)
    end
    
    should "exist" do
      assert @parser
    end
    
    should "parse url images even with queries" do
      font = Hammer::HammerFile.new()
      font.filename = "images/proximanova-regular.eot"
      @hammer_project << font
      
      @css_file = Hammer::HammerFile.new()
      @css_file.filename = "style.css"
      @parser.hammer_file = @css_file
      @parser.text = "a { background: url(proximanova-regular.eot?#iefix) }"
      assert_equal "a { background: url(images/proximanova-regular.eot?#iefix) }", @parser.parse()
    end
    
    should "parse url images even with queries part II" do
      font = Hammer::HammerFile.new()
      font.filename = "images/proximanova-regular.eot"
      @hammer_project << font
      
      @css_file = Hammer::HammerFile.new()
      @css_file.filename = "style.css"
      @parser.hammer_file = @css_file
      @parser.text = "a { background: url(proximanova-regular.eot#iefix) }"
      assert_equal "a { background: url(images/proximanova-regular.eot#iefix) }", @parser.parse()
    end
    
    context "with strange url() params" do
      
      setup do
        @css_file = Hammer::HammerFile.new()
        @css_file.filename = "style.css"
        @parser.hammer_file = @css_file
      end
      
      should "parse empty url()" do
        @parser.text = "a {background: url()}"
        assert_equal "a {background: url()}", @parser.parse()
      end
      
      should "parse multiple url() on one line" do
        image = Hammer::HammerFile.new
        image.filename = "button_bg_over.png"
        @hammer_project << image
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
      
      context "with other files" do
        
        setup do
          @new_file = Hammer::HammerFile.new
          @new_file.raw_text = "a { background: orange; }"
          @new_file.filename = "assets/_include.css"
          @hammer_project << @new_file
          def assert_compilation(pre, post)
            @parser.text = pre
            assert_equal post, @parser.parse()
          end
        end

        should "find scss files when including them" do
          @new_file = Hammer::HammerFile.new
          @new_file.raw_text = "a { background: orange; }"
          @new_file.filename = "assets/_scss_include.scss"
          @hammer_project << @new_file
          
          assert_compilation "url(_scss_include.css)", "url(assets/_scss_include.css)"
        end
        
        should "do paths" do
          assert_compilation "url(_include.css);", "url(assets/_include.css);"
        end

        should "do stupid relative paths" do
          assert_compilation "url(things/like/_include.css);", "url(assets/_include.css);"
        end
        
        context "with multiple paths" do
          setup do
            new_file = Hammer::HammerFile.new
            new_file.filename = "something/assets/_include.css"
            @hammer_project << new_file
          end

          should "match files with matching file paths" do
            assert_compilation "url(assets/_include.css);", "url(assets/_include.css);"
            assert_compilation "url(something/assets/_include.css);", "url(something/assets/_include.css);"
            assert_compilation "url(ing/assets/_include.css);", "url(something/assets/_include.css);"
          end

          should "match absolute file paths" do
            assert_compilation "url(/assets/_include.css);", "url(assets/_include.css);"
          end

        end
        
        should "work with more than one url() on a line with or without a ;" do
          assert_compilation "url(../../_include.css)};url(_include.css)", "url(assets/_include.css)};url(assets/_include.css)"
          assert_compilation "url(../../_include.css)}url(_include.css)", "url(assets/_include.css)}url(assets/_include.css)"
        end
        
        should "work with empty url()" do
          assert_compilation "url()", "url()"
        end

        should "do stupid relative paths again" do
          assert_compilation "url(../../_include.css);", "url(assets/_include.css);"
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
        
        should "do include" do
          assert_compilation "/* @include _include */", "a { background: orange; }"
        end
      end
    end
  end
end
