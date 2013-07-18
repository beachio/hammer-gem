require "tests.rb"

class TestHammerProject < Test::Unit::TestCase
  context "a hammer project" do
    setup do
      @hammer_project = Hammer::Project.new
    end
    
    context "when empty" do
      should "compile" do
        assert @hammer_project.compile()
        assert_equal @hammer_project.hammer_files.length, 0
      end
    end
    
    context "with files" do
      
      setup do
        @header = Hammer::HammerFile.new
        @header.filename = "_header.html"
        @header.raw_text = "header"
        @hammer_project = Hammer::Project.new
        @hammer_project << @header
        Hammer::HammerParser.any_instance.stubs(:parse).returns(@header.text)
      end
      
      should "compile and return hammer files" do
        assert @hammer_project.compile()
        assert_equal @hammer_project.hammer_files.length, 1
        assert_equal @hammer_project.hammer_files.first, @header
        assert_equal @hammer_project.hammer_files.first.text, @header.text
      end
      
      should "find the right parser for a file" do
        assert_equal Hammer.parser_for_extension(@header.extension), Hammer::HTMLParser
      end
      
    end

    context "with markdown files" do
      setup do
        @hammer_project = Hammer::Project.new
        @file = Hammer::HammerFile.new(:filename => "index.md", :hammer_project => @hammer_project)
        @hammer_project << @file
      end
      should "find the markdown file given index.md and html" do
        assert_equal @file, @hammer_project.find_file("index.md", "html")
      end
    end

  end
  
  context "A Hammer project with multiple files" do
    
    setup do
      @header = Hammer::HammerFile.new
      @header.filename = "_header.html"
      
      @style = Hammer::HammerFile.new
      @style.filename = "style.css"
      
      @hammer_project = Hammer::Project.new
      
      @hammer_project << @header
      @hammer_project << @style
      
      @parser = Hammer::HTMLParser.new
    end
    
    should "find the right files with an extension" do
      assert_equal [@header], @hammer_project.find_files("_header", "html")
    end
    
    should "find the right files with an extension when there's another file with the same name" do
      file = Hammer::HammerFile.new(:filename => "header.html")
      @hammer_project << file
      assert_equal [file], @hammer_project.find_files("header", "html")
    end
    
    should "find the right wildcard paths starting with a / (/*.html)" do
      assert_equal [@header], @hammer_project.find_files("/_header", "html")
      assert_equal [], @hammer_project.find_files("assets/*", "html")
      assert_equal [@header], @hammer_project.find_files("/*", "html")
    end
    
    context "when the path is an extension" do
      setup do
        @f = Hammer::HammerFile.new(:filename => "assets/stylesheets/extension_included.scss", :hammer_project => @hammer_project)
        @hammer_project << @f
        @parser.text = "<!-- @stylesheet assets/stylesheets/extension_included.scss -->"
      end
      
      should "find the right files when the path is given with an extension, as a CSS file" do
        assert_equal [@f], @hammer_project.find_files("assets/stylesheets/extension_included.scss", 'css')
      end
    end
    
    context "with an image" do
      setup do
        @image = Hammer::HammerFile.new
        @image.filename = "logo.png"
        @hammer_project << @image
      end
      
      should "find that image" do
        assert_equal [@image], @hammer_project.find_files("logo", "png")
      end
    end
    
  end
  
  context "A basic hammer project" do
    
    setup do
      @hammer_project = Hammer::Project.new
    end
    
    context "with ignore paths" do
      setup do
        @hammer_project.expects(:file_list).returns(['style.css', 'another.css']).at_least_once
        @hammer_project.expects(:ignored_paths).returns(['style.css']).at_least_once
      end
      should "ignore the right files" do
        assert_equal 1, @hammer_project.hammer_files.length
      end
    end
    
  end

  context "A Hammer project with a file" do
    setup do
      @header = Hammer::HammerFile.new
      @header.filename = "_header.html"
      @header.raw_text = "header"
      @hammer_project = Hammer::Project.new
      @hammer_project << @header
      @parser = Hammer::HTMLParser.new
    end

    should "find the right file" do
      
      html_file = Hammer::HammerFile.new
      html_file.filename = "_not_header.html"
      @hammer_project << html_file
      
      new_file = Hammer::HammerFile.new
      new_file.filename = "_not_header.js"
      @hammer_project << new_file
      
      assert_equal [html_file], @hammer_project.find_files('_not_header', 'html')
      assert_equal @hammer_project.find_files('_not_header_1', 'html'), []
      assert_equal @hammer_project.find_files('_not_header_1', 'html'), []
      assert_equal @hammer_project.find_files('_not_header', 'js'), [new_file]
    end

    should "Find an array of files" do
      assert_equal @hammer_project.find_files('_header', "html"), [@header]
    end

    should "Find a file" do
      assert_equal @hammer_project.find_file('_header', "html"), @header
    end
    
    should "prioritze exact filenames" do
      fake_target = Hammer::HammerFile.new(:filename => "a_thing.html")
      @hammer_project << fake_target
      real_target = Hammer::HammerFile.new(:filename => "real/thing.html")
      @hammer_project << real_target
      
      assert_equal real_target, @hammer_project.find_file("thing", "html")
      assert_equal [real_target], @hammer_project.find_files("thing", "html")
    end

  end
end