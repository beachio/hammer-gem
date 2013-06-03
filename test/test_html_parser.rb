require "tests.rb"

class TestHtmlParser < Test::Unit::TestCase
  
  context "An HTML file parser" do
    
    setup do
      @hammer_project       = Hammer::Project.new
      @file                 = Hammer::HammerFile.new(:hammer_project => @hammer_project, :filename => "index.html")
      @hammer_project << @file
      @parser               = Hammer::HTMLParser.new(@hammer_project)
      @parser.hammer_file   = @file
    end
    
    context "with an error" do
      setup do
        @parser.text = "<!-- @path nothing -->"
      end
      
      should "raise an error" do
        assert_raise Hammer::Error do
          @parser.parse
        end
      end
      
      should "have an error with the right line number" do
        begin
          @parser.parse
        rescue Hammer::Error => e 
          assert_equal e.line_number, 1
        end
      end
    end

    should "replace reload tags" do
      @parser.text = "<html><!-- @reload --></html>"
      text = @parser.parse()
      assert !text.include?("@reload"), "It still includes @reload: #{text}"
    end
    
    should "replace placeholder tags" do
      @parser.text = "<html><!-- @placeholder 100x100 --></html>"
      text = @parser.parse()
      assert_equal "<html><img src='http://placehold.it/100x100' width='100' height='100' alt='Placeholder Image' /></html>", text
    end
    
    should "replace placeholder tags with only one dimension" do
      @parser.text = "<html><!-- @placeholder 100 --></html>"
      text = @parser.parse()
      assert_equal "<html><img src='http://placehold.it/100x100' width='100' height='100' alt='Placeholder Image' /></html>", text
    end
    
    should "replace placeholder tags with text" do
      @parser.text = "<html><!-- @placeholder 100x100 I am a teapot --></html>"
      text = @parser.parse()
      assert_equal "<html><img src='http://placehold.it/100x100&text=I+am+a+teapot' width='100' height='100' alt='I am a teapot' /></html>", text
    end
    
    should "replace kitten tags" do
      @parser.text = "<html><!-- @kitten 100x100 --></html>"
      text = @parser.parse()
      assert_equal "<html><img src='http://placekitten.com/100/100' width='100' height='100' alt='Meow' /></html>", text
    end
    
    should "include files" do

    end
    
    context "including files" do
      setup do
        header = Hammer::HammerFile.new
        header.filename = "_header.html"
        header.raw_text = "header"
        @hammer_project << header
      end
      
      should "include files" do
        @parser.text = "<html><!-- @include _header --></html>"
        assert_equal "<html>header</html>", @parser.parse()
      end
    end
    
    should "do placeholders inside include files" do
      header = Hammer::HammerFile.new
      header.filename = "_header.html"
      header.raw_text = "<!-- @placeholder 100x100 -->"
      @hammer_project << header

      @parser.text = "<html><!-- @include _header --></html>"
      # @parser.expects(:find_files).returns([header])
      
      assert_equal "<html><img src='http://placehold.it/100x100' width='100' height='100' alt='Placeholder Image' /></html>", @parser.parse()
    end
    
    context "with script tags" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.raw_text = "I'm an include"
        @new_file.filename = "app.js"
        @hammer_project << @new_file
      
        @file = Hammer::HammerFile.new
        @file.filename = "index.html"
        @file.raw_text = "<!-- @javascript app -->"
        @hammer_project << @file
        
        @parser = Hammer::HTMLParser.new(@hammer_project)
        @parser.hammer_file = @file
        @parser.text = @file.raw_text
      end   
      
      context "single tag" do
        setup do
          @parser.expects(:find_files).returns([@new_file])
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
      
      context "with variables" do
        should "replace @javascript tags" do
          @file.raw_text = "<!-- $variable app --><!-- @javascript $variable -->"
          @new_file.filename = "assets/app.js"
          @parser.text = @file.raw_text
          assert_equal "<script src='assets/app.js'></script>", @parser.parse()
        end
        
        should "raise an error if the variable isn't set" do
          @file.raw_text = "<!-- $variable NOTHING --><!-- @javascript $variable -->"
          @parser.text = @file.raw_text
          # assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
          assert_raises Hammer::Error do
            @parser.parse()
          end
        end 
        
        should "work with Clever Paths" do
          @file.raw_text = "<!-- $variable logo.png --><!-- @path $variable -->"
          image = Hammer::HammerFile.new
          image.filename = "assets/logo.png"
          @hammer_project << image
          @parser.expects(:find_file_without_adding_dependency).returns(image)
          @parser.text = @file.raw_text
          assert_equal "assets/logo.png", @parser.parse()
        end
        
        should "remove empty lines from the start of a page" do
          @file.raw_text = "<!-- $title ABC -->\nThis is a line\nThis is another line"
          @new_file.filename = "assets/app.js"
          @parser.text = @file.raw_text
          assert_equal "This is a line\nThis is another line", @parser.parse()
        end
      end
      
      context "when referring to multiple script tags" do
      
        setup do
          @file.filename = "blog/indessx.html"
          @new_file.filename = "assets/app.js"
          @other_file = @new_file.dup
          @other_file.filename = "assets/x.js"
        end
      
        context "with wildcard script tags" do
          setup do
            @file.raw_text = "<!-- @javascript assets/* -->"
            @parser.hammer_file = @file
            @parser.expects(:find_files).returns([@new_file, @other_file])
          end
          
          should "create multiple <script> tags" do
            assert_equal @parser.parse(), "<script src='../assets/app.js'></script>\n<script src='../assets/x.js'></script>"
          end
        end
      
        context "with multiple script tag invocation" do
          setup do
            @file.raw_text = "<!-- @javascript app x -->"
            @parser.hammer_file = @file
            @parser.expects(:find_files).twice.returns([@new_file, @other_file])
          end
          
          should "create multiple script tags" do
            text = @parser.parse()
            assert_equal "<script src='../assets/app.js'></script>\n<script src='../assets/x.js'></script>", text
          end
        end
      end
    end
    
    context "with stylesheet tags" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.raw_text = "body {display: none}"
        @new_file.filename = "app.css"
        @hammer_project << @new_file
      
        @file = Hammer::HammerFile.new
        @file.filename = "index.html"
        @file.raw_text = "<!-- @stylesheet app -->"
        @hammer_project << @file
        
        @parser = Hammer::HTMLParser.new(@hammer_project)
        @parser.hammer_file = @file
        @parser.text = @file.raw_text
      end   
      
      context "single tag" do
        setup do
          @parser.expects(:find_files).returns([@new_file])
        end
        
        should "replace @stylesheet tags" do
          assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
        end      
        
        should "replace @stylesheet tags with correct paths" do
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

      ## TODO: Re-enable line breaks in tags.
      ## This is quite tricky, though.      
      # should "allow line breaks" do
      #   @third_file = Hammer::HammerFile.new
      #   @third_file.filename = "two.css"
        
      #   @new_file.filename = "assets/three/fail.scss"
      #   @new_file.raw_text = "<!-- @stylesheet xxxxxxx\nyyyyyyy -->"
      #   @parser.hammer_file = @file
      #   @parser.text = @new_file.raw_text
      #   assert_equal "<link rel='stylesheet' href='assets/three/fail.css'>\n<link rel='stylesheet' href='assets/app.css'>", @parser.parse()
      # end
      
      should "replace @stylesheet tags with correct paths for SCSS" do
        @new_file.filename = "assets/three/app.scss"
        @new_file.raw_text = "<!-- @stylesheet app.scss -->"
        @parser.hammer_file = @file
        assert_equal "<link rel='stylesheet' href='assets/three/app.css'>", @parser.parse()
      end
      
      context "with variables" do
        should "replace @stylesheet tags" do
          @file.raw_text = "<!-- $variable app --><!-- @stylesheet $variable -->"
          @parser.text = @file.raw_text
          assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
        end
        
        should "raise an error if the variable isn't set" do
          @file.raw_text = "<!-- $variable NOTHING --><!-- @stylesheet $variable -->"
          @parser.text = @file.raw_text
          # assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
          assert_raises Hammer::Error do
            @parser.parse()
          end
        end 
      end
      
      context "when referring to multiple stylesheet tags" do
      
        setup do
          @file.filename = "blog/index.html"
          @new_file.filename = "assets/app.css"
          @other_file = @new_file.dup
          @other_file.filename = "assets/x.css"
        end
      
        context "with wildcard script tags" do
          setup do
            @file.raw_text = "<!-- @stylesheet assets/* -->"
            @parser.hammer_file = @file
            @parser.expects(:find_files).returns([@new_file, @other_file])
          end
          
          should "write this test" do
            assert_equal @parser.parse(), "<link rel='stylesheet' href='../assets/app.css'>\n<link rel='stylesheet' href='../assets/x.css'>"
          end
        end
      
        context "with multiple stylesheet tag invocation" do
          setup do
            @parser.expects(:find_files).twice.returns([@new_file, @other_file])
            @file.raw_text = "<!-- @stylesheet app x -->"
            @parser.hammer_file = @file
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
      
      should "add a current class to a link to the same page when in a folder and with a path tag" do
        @file.filename = "blog/index.html"
        @file.raw_text = "<a href='<!-- @path index -->'></a>"
        @parser.hammer_file = @file
        @parser.text = @file.raw_text
        assert_equal "<a class='current-parent current' href='index.html'></a>", @parser.parse()
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
        @parser.expects(:find_file_without_adding_dependency).returns(logo)
        @parser.hammer_file = @file
      end
      
      should "replace path tags" do
        text = @parser.parse()
        assert_equal "../images/logo.png", text
      end
      
      should "also replace @path tags inside attributes" do
        @parser.text = "<img src='@path logo.png' />"
        text = @parser.parse()
        assert_equal "<img src='../images/logo.png' />", text
      end
    end
    
    context "when just parsing variables" do
      setup do
        @parser = Hammer::HTMLParser.new(@hammer_project)
      end
      
      should "work with normal variables" do
        @file.raw_text = "<!-- $title B -->"
        @parser.hammer_file = @file

        assert_equal "", @parser.parse()
      end

      should "work with a variable with | in its name" do
        @file.raw_text = "<!-- $title This is my title | I am cool --><!-- $title -->"
        @parser.hammer_file = @file

        assert_equal "This is my title | I am cool", @parser.parse()
      end

      
      should "work with a variable with > in its name" do
        @file.raw_text = "<!-- $title B> -->"
        @parser.hammer_file = @file

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
    
    context "when retrieving variables with a default" do
      setup do
        @file.raw_text = "<!-- $title | Here's the title -->"
        @parser.text = @file.raw_text
      end
      
      should "work" do
        assert_equal "Here's the title", @parser.parse()
      end
    end
    
    context "when parsing current links" do
      setup do
        @file.filename = "index.html"
        @parser.hammer_file = @file
      end
      should "add a current class to a link to the same page when using a path" do
        @file.raw_text = "<a href='<!-- @path index -->'></a>"
        @parser.text = @file.raw_text
        assert_equal "<a class='current' href='index.html'></a>", @parser.parse()
      end
    end
  end
  
  context "when including files" do
    setup do
      @hammer_project = Hammer::Project.new
      @file = Hammer::HammerFile.new
      @file.raw_text = "<!-- @include _header -->"
      @file.filename = "index.html"
      @file.hammer_project = @hammer_project
      @hammer_project << @file
    end
    
    context "in other directories" do
      setup do
        f1 = Hammer::HammerFile.new
        f1.filename = "blog/index.html"
        @hammer_project << f1
        
        @f2 = Hammer::HammerFile.new
        @f2.filename = "about/index.html"
        @hammer_project << @f2
        
        @file.raw_text = "<!-- @path about/index.html -->"
      end
      
      should "do path tags right" do
        parser = Hammer.parser_for_hammer_file(@file)
        assert_equal [@f2], parser.find_files('about/index.html', 'html')
        assert_equal "about/index.html", parser.parse()
      end
    end
    
    context "including a HAML file" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.raw_text = "haml file"
        @new_file.filename = "_header.haml"
        @new_file.hammer_project = @hammer_project
        @hammer_project << @new_file
      end
      
      should "include the file" do
        parser = Hammer.parser_for_hammer_file(@file)
        assert_equal [@new_file], parser.find_files("_header.haml", 'html')
        assert parser.parse().include? "haml file"
      end
    end
    
    context "including a file" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.raw_text = "Header"
        @new_file.filename = "_header.html"
        @new_file.hammer_project = @hammer_project
        @hammer_project << @new_file
      end
      
      should "include the file" do
        assert @new_file.extension
        assert_equal Hammer::HTMLParser, Hammer.parser_for_hammer_file(@file).class
        assert_equal "Header", Hammer.parser_for_hammer_file(@file).parse()
      end
      
      should "carry over variables from included files" do
        @file.raw_text = "<!-- @include _header --><!-- $title -->"
        @new_file.raw_text = "<!-- $title A -->"
        parser = Hammer.parser_for_hammer_file(@file)
        assert_equal "A", parser.parse()
        assert_equal({'title' => "A"}, parser.send(:variables))
      end
      
      should "set variables for included files" do
        @file.raw_text = "<!-- $title A --><!-- @include _header -->"
        @new_file.raw_text = "<!-- $title -->"
        parser = Hammer.parser_for_hammer_file(@file)
        assert_equal "A", parser.parse()
        assert_equal({'title' => "A"}, parser.send(:variables))        
      end
      
      context "with variables set" do
        setup do
        end
        
        should "use variables in include tags" do
          @file.raw_text = "<!-- $name _header --><!-- @include $name -->"
          parser = Hammer.parser_for_hammer_file(@file)
          assert_equal "Header", parser.parse()
          assert_equal({'name' => "_header"}, parser.send(:variables))     
        end
      end
    end
    
  end
  
end