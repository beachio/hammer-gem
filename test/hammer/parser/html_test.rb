require "test_helper.rb"

class TestHtmlParser < Test::Unit::TestCase
  
  context "An HTML file parser" do

    setup do
      @parser = Hammer::HTMLParser.new()
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

    should "Retrieve variables" do
      @parser.text = "<!-- $title Here's the title --><!-- $title -->"
      assert_equal "Here's the title", @parser.parse()
    end
    
    should "retrieve defaults for variables" do
      @parser.text = "<!-- $title | Here's the title -->"
      assert_equal "Here's the title", @parser.parse()
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

    should "raise an error when including the wrong file" do
      @parser.text = "<html><!-- @include _header --></html>"
      assert_raises Hammer::Error do
        @parser.parse()
      end
    end

    should "raise an error when including an unset variable" do
      @parser.text = "<html><!-- @include $header --></html>"
      assert_raises Hammer::Error do
        @parser.parse()
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

    should "replace @javascript tags in optimized" do
      file = Hammer::HammerFile.new :text => "I'm an include", :filename => 'a/b/c/app.js'
      other_file = Hammer::HammerFile.new :text => "I'm an include", :filename => 'a/b/c/style.js'
      @parser.stubs(:find_files).returns([file, other_file])
      @parser.stubs(:optimized).returns(true)
      @parser.text = "<!-- @javascript app style -->"
      assert @parser.parse().include? "script src="
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

    should "correctly match Clever Paths with alternative syntax" do
      @parser.text = "'@path location/index.html'"
      b = Hammer::HammerFile.new(:text => "I'm the right file.", :filename => "1234567890/location/index.html")
      @parser.stubs(:find_files).returns([b])
      assert_equal "'1234567890/location/index.html'", @parser.parse()
    end

    should "raise an error for clever paths if the file isn't found" do

      file = Hammer::HammerFile.new(:filename => "a")
      @parser = Hammer::HTMLParser.new(:hammer_file => file)
      @parser.text = '<!-- @path location/index.html -->'
      @parser.stubs(:find_files).returns([])

      assert_raises do
        @parser.parse()
      end

      assert @parser.hammer_file.error
      assert @parser.hammer_file.error.message.to_s.include? "Path tags:"

      ["'@path location/index.html'", '"@path location/index.html"', "<!-- @path location/index.html -->"].each do |text|
        @parser.text = text
        assert_raises Hammer::Error do
          @parser.parse()
        end
      end
    end

    should "correctly match Clever Paths with alternative syntax with doublequotes" do
      @parser.text = '"@path location/index.html"'
      b = Hammer::HammerFile.new(:text => "I'm the right file.", :filename => "1234567890/location/index.html")
      @parser.stubs(:find_files).returns([b])
      assert_equal '"1234567890/location/index.html"', @parser.parse()
    end
  
    should "remove empty lines from the start of a page" do
      @parser.text = "<!-- $title ABC -->\nThis is a line\nThis is another line"
      assert_equal "This is a line\nThis is another line", @parser.parse()
    end
    
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

      should "create a single tag when in optimized" do
        @parser.text = "<!-- @stylesheet app x -->"
        @parser.stubs(:optimized).returns(true)
        # assert_equal "<link rel='stylesheet' href='../assets/app.css'>\n<link rel='stylesheet' href='../assets/x.css'>", @parser.parse()
        text = @parser.parse()
        assert_equal text.scan(/style/).count, 1
      end
    end
    
    context "with variables" do

      should "read variables with backups" do
        @parser.text = "<!-- $variable | yes -->"
        assert_equal "yes", @parser.parse()
      end

      should "raise errors for variable tags and path tags with unset variables" do
        [
          "<!-- @path $unset_variable -->", 
          "<!-- $unset_variable -->"
        ].each do |html|
          @parser.text = html
          error = assert_raises Hammer::Error do
            @parser.parse()
          end
          assert error
          assert error.message.to_s.include? "wasn't set"
        end
      end

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
      
    should "include a file with errors" do
      included_file = Hammer::HammerFile.new(:text => "<!-- $unset_variable -->", :filename => "include.html")
      file = Hammer::HammerFile.new(:text => "<!-- @include include -->", :filename => "index.html")
      @parser = Hammer::HTMLParser.new(:hammer_file => file)
      @parser.stubs(:find_files).returns([included_file])

      assert_raises Hammer::Error do
        @parser.parse()
      end
    end

    should "raise an error not finding a file" do
      included_file = Hammer::HammerFile.new(:text => "<!-- $unset_variable -->", :filename => "include.html")
      file = Hammer::HammerFile.new(:text => "<!-- @include include -->", :filename => "index.html")
      @parser = Hammer::HTMLParser.new(:hammer_file => file)
      @parser.stubs(:find_files).returns([])

      assert_raises Hammer::Error do
        @parser.parse()
      end
    end

    should "work with normal variables" do
      @parser.text = "<!-- $title B -->"
      assert_equal "", @parser.parse()
    end

    should "work with a variable with | in its name" do
      @parser.text =  "<!-- $title This is my title | I am cool --><!-- $title -->"
      assert_equal "This is my title | I am cool", @parser.parse()
    end
    
    should "work with a variable with > in its name - getting" do
      @parser.text = "<!-- $title B> -->"
      assert_equal "", @parser.parse()
    end

    should "Work with a variable with > in its value - getting and setting" do
      @parser.text = "<!-- $title B> --><!-- $title -->"
      assert_equal "B>", @parser.parse()
    end
  
    context "including a HAML file" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.raw_text = "haml file"
        @new_file.filename = "_header.haml"
        @new_file.hammer_project = @hammer_project
      end
      
      should "include the file" do
        @parser.text = "<!-- @include _header -->"
        @parser.stubs(:find_files).with('_header', 'html').returns([@new_file])
        assert @parser.parse().include? "haml file"
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

    context "including a file" do
      setup do
        @new_file = Hammer::HammerFile.new
        @new_file.raw_text = "Header"
        @new_file.filename = "_header.html"
        @new_file.hammer_project = @hammer_project
        @hammer_project << @new_file
        @parser = Hammer::HTMLParser.new()
      end
      
      should "include the file" do
        @parser.text = "<!-- @include _header -->"
        @parser.expects(:find_files).with('_header', 'html').returns([@new_file])
        assert_equal "Header", @parser.parse()
      end
      
      should "use variables in include tags" do
        begin
          @parser.text = "<!-- $name _header --><!-- @include $name -->"
          @parser.stubs(:find_files).returns [Hammer::HammerFile.new(:text => "Header", :filename => "_header.html")]
          assert_equal "Header", @parser.parse()
          assert_equal({'name' => "_header"}, @parser.send(:variables))
        end
      end
      
      should "carry over variables from included files" do
        begin
          @parser.text = "<!-- @include _header --><!-- $title -->"
          @parser.expects(:find_files).with('_header', 'html').returns([Hammer::HammerFile.new(:text => "<!-- $title A -->", :filename => "_header.html")])
          assert_equal "A", @parser.parse()
          assert_equal({'title' => "A"}, @parser.send(:variables))
        end
      end
      
      should "set variables for included files" do
        @new_file.raw_text = "<!-- $title -->"
        @parser.text = "<!-- $title A --><!-- @include _header -->"
        @parser.expects(:find_files).with('_header', 'html').returns([@new_file])
        assert_equal "A", @parser.parse()
        assert_equal({'title' => "A"}, @parser.send(:variables))        
      end
    end
  end

  context "with an error" do
    setup do
      @parser = Hammer::HTMLParser.new(:text => "<!-- @path nothing -->")
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
  
end