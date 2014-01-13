require "test_helper.rb"

class TestHtmlParser < Test::Unit::TestCase
  
  context "An HTML file parser" do

    setup do
      @parser               = Hammer::HTMLParser.new()
    end

    should "replace reload tags" do
      @parser.text = "<html><!-- @reload --></html>"
      assert !@parser.parse().include?("@reload")
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

    context "with another file" do
      setup do
        @header = Hammer::HammerFile.new(:filename => "_header.html", :text => "header")
        @parser.stubs(:find_files).returns([@header])
      end

      should "include the file" do
        @parser.text = "<html><!-- @include _header --></html>"
        assert_equal "<html>header</html>", @parser.parse()
      end
    end

    should "do placeholders inside include files" do
      @header = Hammer::HammerFile.new(:filename => "_header.html", :text => "header")
      @parser.stubs(:find_files).returns([@header])
      @header.raw_text = "<!-- @placeholder 100x100 -->"
      @parser.text = "<html><!-- @include _header --></html>"
      @parser.expects(:find_files).returns([@header])
      assert_equal "<html><img src='http://placehold.it/100x100' width='100' height='100' alt='Placeholder Image' /></html>", @parser.parse()
    end

    should "replace @javascript tags" do
      new_file = Hammer::HammerFile.new :text => "I'm an include", :filename => 'a/b/c/app.js'
      @parser.text = "<!-- @javascript app -->"
      @parser.stubs(:find_files).returns([new_file])
      assert_equal "<script src='a/b/c/app.js'></script>", @parser.parse()
    end

    should "replace @javascript tags with $variable filenames." do
      new_file = Hammer::HammerFile.new :filename => "assets/app.js"
      @parser.stubs(:find_files).returns([new_file])
      @parser.text = "<!-- $variable app --><!-- @javascript $variable -->"
      assert_equal "<script src='assets/app.js'></script>", @parser.parse()
    end

    should "work with Clever Paths" do
      image = Hammer::HammerFile.new :filename => "assets/logo.png"
      @parser.expects(:find_file).returns(image)
      @parser.text = "<!-- $variable logo.png --><!-- @path $variable -->"
      assert_equal "assets/logo.png", @parser.parse()
    end

    should "raise an error if the variable isn't set" do
      @parser.text = "<!-- $variable NOTHING --><!-- @javascript $variable -->"
      assert_raises Hammer::Error do
        @parser.parse()
      end
    end


    should "correctly match Clever Paths" do
      @parser.text = "<!-- @path location/index.html -->"
      b = Hammer::HammerFile.new(:text => "I'm the right file.", :filename => "1234567890/location/index.html")
      @parser.stubs(:find_files).returns([b])
      assert_equal "1234567890/location/index.html", @parser.parse()
    end
  
      should "remove empty lines from the start of a page" do
        @parser.text = "<!-- $title ABC -->\nThis is a line\nThis is another line"
        assert_equal "This is a line\nThis is another line", @parser.parse()
      end
    
    # should "replace script tags" do

  #   context "with script tags" do
  #     setup do
  #       @new_file = Hammer::HammerFile.new
  #       @new_file.raw_text = "I'm an include"
  #       @new_file.filename = "app.js"
  #       @hammer_project << @new_file
      
  #       @file = Hammer::HammerFile.new
  #       @file.filename = "index.html"
  #       @file.raw_text = "<!-- @javascript app -->"
  #       @hammer_project << @file
        
  #       @parser = Hammer::HTMLParser.new(@hammer_project)
  #       @parser.hammer_file = @file
  #       @parser.text = @file.raw_text
  #     end   
      
  #     context "single tag" do
  #       setup do
  #         @parser.expects(:find_files).returns([@new_file])
  #       end
        

        
  #     end
      

      context "when referring to multiple script tags" do
        setup do
          @parser.stubs(:filename).returns('about/index.html')
          @app = Hammer::HammerFile.new :filename => "assets/app.js"
          @x = Hammer::HammerFile.new :filename => "assets/x.js"
          @parser.stubs(:find_files).returns([@app, @x])
        end
      
        should "create multiple tags with wildcards" do
          @parser.text = "<!-- @javascript assets/* -->"
          assert_equal "<script src='../assets/app.js'></script>\n<script src='../assets/x.js'></script>", @parser.parse()
        end
      
        should "create multiple tags without wildcards" do
          @parser.text = "<!-- @javascript app x -->"
          assert_equal "<script src='../assets/app.js'></script>\n<script src='../assets/x.js'></script>", @parser.parse()
        end
      end


      context "when referring to multiple stylesheet tags" do
        setup do
          @parser.stubs(:filename).returns('about/index.html')
          @app = Hammer::HammerFile.new :filename => "assets/app.css"
          @x = Hammer::HammerFile.new :filename => "assets/x.css"
          @parser.stubs(:find_files).returns([@app, @x])
        end
      
        should "create multiple tags with wildcards" do
          @parser.text = "<!-- @stylesheet assets/* -->"
          assert_equal "<link rel='stylesheet' href='../assets/app.css'>\n<link rel='stylesheet' href='../assets/x.css'>", @parser.parse()
        end
      
        should "create multiple tags without wildcards" do
          @parser.text = "<!-- @stylesheet app x -->"
          assert_equal "<link rel='stylesheet' href='../assets/app.css'>\n<link rel='stylesheet' href='../assets/x.css'>", @parser.parse()
        end
      end
    
  #   context "with stylesheet tags" do

  #     context "single tag" do
  #       setup do
  #         @parser.expects(:find_files).returns([@new_file])
  #       end
        
  #       should "replace @stylesheet tags" do
  #         assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
  #       end      
        
  #       should "replace @stylesheet tags with correct paths" do
  #         @new_file.filename = "assets/app.css"
  #         @parser.hammer_file = @file
  #         assert_equal "<link rel='stylesheet' href='assets/app.css'>", @parser.parse()
  #       end
        
  #       should "replace @javascript tags with correct paths in another directory" do
  #         @file.filename = "blog/index.html"
  #         @new_file.filename = "assets/app.css"
  #         @parser.hammer_file = @file
  #         assert_equal "<link rel='stylesheet' href='../assets/app.css'>", @parser.parse()
  #       end
  #     end

  #     ## TODO: Re-enable line breaks in tags.
  #     ## This is quite tricky, though.      
  #     # should "allow line breaks" do
  #     #   @third_file = Hammer::HammerFile.new
  #     #   @third_file.filename = "two.css"
        
  #     #   @new_file.filename = "assets/three/fail.scss"
  #     #   @new_file.raw_text = "<!-- @stylesheet xxxxxxx\nyyyyyyy -->"
  #     #   @parser.hammer_file = @file
  #     #   @parser.text = @new_file.raw_text
  #     #   assert_equal "<link rel='stylesheet' href='assets/three/fail.css'>\n<link rel='stylesheet' href='assets/app.css'>", @parser.parse()
  #     # end
      
  #     should "replace @stylesheet tags with correct paths for SCSS" do
  #       @new_file.filename = "assets/three/app.scss"
  #       @new_file.raw_text = "<!-- @stylesheet app.scss -->"
  #       @parser.hammer_file = @file
  #       assert_equal "<link rel='stylesheet' href='assets/three/app.css'>", @parser.parse()
  #     end
      
      context "with variables" do
        should "replace @stylesheet tags" do
          @parser.text = "<!-- $variable app --><!-- @stylesheet $variable -->"
          new_file = Hammer::HammerFile.new(:filename => "app.css")
          @parser.stubs(:find_files).returns([new_file])
          assert_equal "<link rel='stylesheet' href='app.css'>", @parser.parse()
        end
        
        should "raise an error if the variable isn't set" do
          @parser.stubs(:find_files).returns([])
          @parser.text = "<!-- $variable NOTHING --><!-- @stylesheet $variable -->"
          assert_raises Hammer::Error do
            @parser.parse()
          end
        end 
      end
      

    
    context "with links" do
      setup do
        # @file.filename = "index.html"
        # @parser.hammer_file = @file
      end

      should "Amp the file" do
        Amp.expects(:compile).at_least_once
        @parser.text = "<a href='index.html'></a>"
        @parser.stubs(:filename).returns "index.html"
        @parser.parse()
      end
      
  #     should "add a current class to a link to the same page" do
  #       @file.raw_text = "<a href='index.html'></a>"
  #       @parser.text = @file.raw_text
  #       assert_equal "<a class='current' href='index.html'></a>", @parser.parse()
  #     end
      
  #     should "add a current class to a link to the same page when in a folder and with a path tag" do
  #       @file.filename = "blog/index.html"
  #       @file.raw_text = "<a href='<!-- @path index -->'></a>"
  #       @parser.hammer_file = @file
  #       @parser.text = @file.raw_text
  #       assert_equal "<a class='current' href='index.html'></a>", @parser.parse()
  #     end
            
  #     should "not add a current class to a link to a different page" do
  #       @file.raw_text = "<a href='_header.html'></a>"
  #       @parser.text = @file.raw_text
  #       assert_equal "<a href='_header.html'></a>", @parser.parse()
  #     end
      
  #     should "add a class to the surrounding li" do
  #       @file.raw_text = "<li><a href='index.html'></a></li>"
  #       @parser.text = @file.raw_text
  #       assert_equal "<li class='current'><a class='current' href='index.html'></a></li>", @parser.parse()
  #     end
      
  #     should "not add a class to the surrounding li if the URL is wrong" do
  #       @file.raw_text = "<li><a href='_header.html'></a></li>"
  #       @parser.text = @file.raw_text
  #       assert_equal "<li><a href='_header.html'></a></li>", @parser.parse()
  #     end
    end
    
  #   context "when parsing path tags" do
  #     setup do
  #       @file.filename = "blog/index.html"
  #       @file.raw_text = "<!-- @path logo.png -->"
  #       logo = Hammer::HammerFile.new
  #       logo.filename = "images/logo.png"
  #       @hammer_project << logo
  #       @parser.hammer_file = @file
  #     end
      
  #     should "replace path tags" do
  #       text = @parser.parse()
  #       assert_equal "../images/logo.png", text
  #     end
      
  #     should "replace path tags that are variables" do
  #       @file.raw_text = "<!-- $file logo.png --> Testing <!-- @path $file -->"
  #       @parser.text = @file.raw_text
  #       @parser.hammer_file = @file
  #       text = @parser.parse()
  #       assert_equal " Testing ../images/logo.png", text
  #     end
      
  #     should "also replace @path tags inside attributes" do
  #       @parser.text = "<img src='@path logo.png' />"
  #       text = @parser.parse()
  #       assert_equal "<img src='../images/logo.png' />", text
  #     end
  #   end
    
  #   context "when just parsing variables" do
  #     setup do
  #       @parser = Hammer::HTMLParser.new(@hammer_project)
  #     end
      
  #     should "work with normal variables" do
  #       @file.raw_text = "<!-- $title B -->"
  #       @parser.hammer_file = @file

  #       assert_equal "", @parser.parse()
  #     end

  #     should "work with a variable with | in its name" do
  #       @file.raw_text = "<!-- $title This is my title | I am cool --><!-- $title -->"
  #       @parser.hammer_file = @file

  #       assert_equal "This is my title | I am cool", @parser.parse()
  #     end

      
  #     should "work with a variable with > in its name" do
  #       @file.raw_text = "<!-- $title B> -->"
  #       @parser.hammer_file = @file

  #       assert_equal "", @parser.parse()
  #     end
  #   end

  #   context "when retrieving variables" do
  #     setup do
  #       @file.raw_text = "<!-- $title Here's the title --><!-- $title -->"
  #       @parser.text = @file.raw_text
  #     end
      
  #     should "work" do
  #       assert_equal "Here's the title", @parser.parse()
  #     end
  #   end
    
  #   context "when retrieving variables with a default" do
  #     setup do
  #       @file.raw_text = "<!-- $title | Here's the title -->"
  #       @parser.text = @file.raw_text
  #     end
      
  #     should "work" do
  #       assert_equal "Here's the title", @parser.parse()
  #     end
  #   end
    
  #   context "when parsing current links" do
  #     setup do
  #       @file.filename = "index.html"
  #       @parser.hammer_file = @file
  #     end
  #     should "add a current class to a link to the same page when using a path" do
  #       @file.raw_text = "<a href='<!-- @path index -->'></a>"
  #       @parser.text = @file.raw_text
  #       assert_equal "<a class='current' href='index.html'></a>", @parser.parse()
  #     end
  #   end
  # end
  
  # context "when including files" do
  #   setup do
  #     @hammer_project = Hammer::Project.new
  #     @file = Hammer::HammerFile.new
  #     @file.raw_text = "<!-- @include _header -->"
  #     @file.filename = "index.html"
  #     @file.hammer_project = @hammer_project
  #     @hammer_project << @file
  #   end
    
  #   context "in other directories" do
  #     setup do
  #       f1 = Hammer::HammerFile.new
  #       f1.filename = "blog/index.html"
  #       @hammer_project << f1
        
  #       @f2 = Hammer::HammerFile.new
  #       @f2.filename = "about/index.html"
  #       @hammer_project << @f2
        
  #       @file.raw_text = "<!-- @path about/index.html -->"
  #     end
      
  #     should "do path tags right" do
  #       parser = Hammer::HTMLParser.new(:text => @file.raw_text)
  #       assert_equal [@f2], parser.find_files('about/index.html', 'html')
  #       assert_equal "about/index.html", parser.parse()
  #     end
  #   end
    
  #   context "including a HAML file" do
  #     setup do
  #       @new_file = Hammer::HammerFile.new
  #       @new_file.raw_text = "haml file"
  #       @new_file.filename = "_header.haml"
  #       @new_file.hammer_project = @hammer_project
  #       @hammer_project << @new_file
  #     end
      
  #     should "include the file" do
  #       parser = Hammer::HTMLParser.new(:text => @file.raw_text)
  #       assert_equal [@new_file], parser.find_files("_header.haml", 'html')
  #       assert parser.parse().include? "haml file"
  #     end
  #   end
    
  #   context "including a file" do
  #     setup do
  #       @new_file = Hammer::HammerFile.new
  #       @new_file.raw_text = "Header"
  #       @new_file.filename = "_header.html"
  #       @new_file.hammer_project = @hammer_project
  #       @hammer_project << @new_file
  #     end
      
  #     should "include the file" do
  #       assert @new_file.extension
  #       assert_equal "Header", Hammer::HTMLParser.new(:text => @file.raw_text).parse()
  #     end
      
  #     should "carry over variables from included files" do
  #       @file.raw_text = "<!-- @include _header --><!-- $title -->"
  #       @new_file.raw_text = "<!-- $title A -->"
  #       parser = Hammer.parser_for_hammer_file(@file)
  #       assert_equal "A", parser.parse()
  #       assert_equal({'title' => "A"}, parser.send(:variables))
  #     end
      
  #     should "set variables for included files" do
  #       @file.raw_text = "<!-- $title A --><!-- @include _header -->"
  #       @new_file.raw_text = "<!-- $title -->"
  #       parser = Hammer.parser_for_hammer_file(@file)
  #       assert_equal "A", parser.parse()
  #       assert_equal({'title' => "A"}, parser.send(:variables))        
  #     end
      
  #     context "with variables set" do
  #       setup do
  #       end
        
  #       should "use variables in include tags" do
  #         @file.raw_text = "<!-- $name _header --><!-- @include $name -->"
  #         parser = Hammer.parser_for_hammer_file(@file)
  #         assert_equal "Header", parser.parse()
  #         assert_equal({'name' => "_header"}, parser.send(:variables))     
  #       end
  #     end
  #   end

    #   context "with an error" do
  #     setup do
  #       @parser.text = "<!-- @path nothing -->"
  #     end
      
  #     should "raise an error" do
  #       assert_raise Hammer::Error do
  #         @parser.parse
  #       end
  #     end
      
  #     should "have an error with the right line number" do
  #       begin
  #         @parser.parse
  #       rescue Hammer::Error => e 
  #         assert_equal e.line_number, 1
  #       end
  #     end
  #   end
    
  end
  
end