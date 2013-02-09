require "./tests.rb"
class TestHtmlParser < Test::Unit::TestCase
  context "An HTML file parser" do
    setup do
      @hammer_project       = Hammer::Project.new
      @file                 = Hammer::HammerFile.new
      @hammer_project << @file
      @file.hammer_project  = @hammer_project
      @parser               = Hammer::HTMLParser.new(@hammer_project)
      @parser.hammer_file   = @file
    end

    should "replace reload tags" do
      @parser.text = "<html><!-- @reload --></html>"
      text = @parser.parse()
      assert !text.include?("@reload"), "It still includes @reload: #{text}"
    end

    should "include files" do
      header = Hammer::HammerFile.new
      header.filename = "_header.html"
      header.text = "header"
      header.expects(:to_html).returns("header")
      @hammer_project << header

      @parser.text = "<html><!-- @include _header --></html>"
      @hammer_project.expects(:find_file).returns(header)
      
      assert_equal "<html>header</html>", @parser.parse()
    end
    
    context "with script tags" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.text = "I'm an include"
        @new_file.filename = "app.js"
        @hammer_project << @new_file
      
        @file = Hammer::HammerFile.new
        @file.filename = "index.html"
        @file.text = "<!-- @javascript app -->"
        @hammer_project << @file
        
        @parser = @file.parser.new(@hammer_project)
        @parser.hammer_file = @file
        @parser.text = @file.raw_text
      end   
      
      context "single tag" do
        setup do
          @hammer_project.expects(:find_files).returns([@new_file])
        end
        
        should "replace @javascript tags" do
          assert_equal "<script src='app.js'></script>", @parser.parse()
        end      
        
        should "replace @javascript tags with correct paths" do
          @new_file.filename = "assets/app.js"
          @parser.hammer_file = @file
          assert_equal "<script src='assets/app.js'></script>", @parser.parse()
        end
        
        should "replace @javascript tags with correct paths" do
          @file.filename = "blog/index.html"
          @new_file.filename = "assets/app.js"
          @parser.hammer_file = @file
          assert_equal "<script src='../assets/app.js'></script>", @parser.parse()
        end
      end
      
      context "when referring to multiple script tags" do
      
        setup do
          @file.filename = "blog/index.html"
          @new_file.filename = "assets/app.js"
          @other_file = @new_file.dup
          @other_file.filename = "assets/x.js"
          @hammer_project.expects(:find_files).returns([@new_file, @other_file])
        end
      
        context "with wildcard script tags" do
          setup do
            @file.text = "<!-- @javascript assets/* -->"
            @parser.hammer_file = @file
          end
          
          should "write this test" do
            assert_equal @parser.parse(), "<script src='../assets/app.js'></script>\n<script src='../assets/x.js'></script>"
          end
        end
      
        context "with multiple script tag invocation" do
          setup do
            @file.text = "<!-- @javascript app x -->"
            # @parser.hammer_file = @file
          end
          
          should "create multiple script tags" do
            assert_equal @parser.parse(), "<script src='../assets/app.js'></script>\n<script src='../assets/x.js'></script>"
          end
        end
      end
    end

  end
end