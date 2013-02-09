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
        
        should "replace @javascript tags with correct paths in another directory" do
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
    
    context "with stylesheet tags" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.text = "body {display: none}"
        @new_file.filename = "app.css"
        @hammer_project << @new_file
      
        @file = Hammer::HammerFile.new
        @file.filename = "index.html"
        @file.text = "<!-- @stylesheet app -->"
        @hammer_project << @file
        
        @parser = @file.parser.new(@hammer_project)
        @parser.hammer_file = @file
        @parser.text = @file.raw_text
      end   
      
      context "single tag" do
        setup do
          @hammer_project.expects(:find_files).returns([@new_file])
        end
        
        should "replace @stylesheet tags" do
          assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
        end      
        
        should "replace @javascript tags with correct paths" do
          @new_file.filename = "assets/app.css"
          @parser.hammer_file = @file
          assert_equal "<link rel='stylesheet' href='assets/app.css'>", @parser.parse()
        end
        
        should "replace @javascript tags with correct paths in another directory" do
          @file.filename = "blog/index.html"
          @new_file.filename = "assets/app.css"
          @parser.hammer_file = @file
          assert_equal "<link rel='stylesheet' href='../assets/app.css'>", @parser.parse()
        end
      end
      
      context "when referring to multiple stylesheet tags" do
      
        setup do
          @file.filename = "blog/index.html"
          @new_file.filename = "assets/app.css"
          @other_file = @new_file.dup
          @other_file.filename = "assets/x.css"
          @hammer_project.expects(:find_files).returns([@new_file, @other_file])
        end
      
        context "with wildcard script tags" do
          setup do
            @file.text = "<!-- @stylesheet assets/* -->"
            @parser.hammer_file = @file
          end
          
          should "write this test" do
            assert_equal @parser.parse(), "<link rel='stylesheet' href='../assets/app.css'>\n<link rel='stylesheet' href='../assets/x.css'>"
          end
        end
      
        context "with multiple stylesheet tag invocation" do
          setup do
            @file.text = "<!-- @stylesheet app x -->"
            # @parser.hammer_file = @file
          end
          
          should "create multiple script tags" do
            assert_equal @parser.parse(), "<link rel='stylesheet' href='../assets/app.css'>\n<link rel='stylesheet' href='../assets/x.css'>"
          end
        end
      end
    end
    
    context "with links" do
      setup do
        @file.filename = "index.html"
        @parser.hammer_file = @file
      end
      
      should "add a current class to a link to the same page" do
        @file.raw_text = "<a href='index.html'></a>"
        @parser.text = @file.raw_text
        assert_equal "<a class='current' href='index.html'></a>", @parser.parse()
      end
      
      should "not add a current class to a link to a different page" do
        @file.raw_text = "<a href='_header.html'></a>"
        @parser.text = @file.raw_text
        assert_equal "<a href='_header.html'></a>", @parser.parse()
      end
      
      should "add a class to the surrounding li" do
        @file.raw_text = "<li><a href='index.html'></a></li>"
        @parser.text = @file.raw_text
        assert_equal "<li class='current'><a class='current' href='index.html'></a></li>", @parser.parse()
      end
      
      should "not add a class to the surrounding li if the URL is wrong" do
        @file.raw_text = "<li><a href='_header.html'></a></li>"
        @parser.text = @file.raw_text
        assert_equal "<li><a href='_header.html'></a></li>", @parser.parse()
      end
    end
    
    context "when parsing path tags" do
      setup do
        @file.filename = "blog/index.html"
        @file.raw_text = "<!-- @path logo.png -->"
        logo = Hammer::HammerFile.new
        logo.filename = "images/logo.png"
        @hammer_project << logo
        @hammer_project.expects(:find_file).returns(logo)
      end
      
      should "replace path tags" do
        @parser.text = @file.raw_text
        text = @parser.parse()
        assert_equal "../images/logo.png", text
      end
    end
    
    context "when just parsing variables" do
      setup do
        @file.raw_text = "<!-- $title A -->"
        @parser.text = @file.raw_text
      end
      
      should "work" do
        assert_equal "", @parser.parse()
      end
    end

    context "when retrieving variables" do
      setup do
        @file.raw_text = "<!-- $title Here's the title --><!-- $title -->"
        @parser.text = @file.raw_text
      end
      
      should "work" do
        assert_equal "Here's the title", @parser.parse()
      end
    end
    
    context "when retrieving variables" do
      setup do
        @file.raw_text = "<!-- $title | Here's the title -->"
        @parser.text = @file.raw_text
      end
      
      should "work" do
        assert_equal "Here's the title", @parser.parse()
      end
    end
    
  end
end