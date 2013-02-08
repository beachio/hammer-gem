require "./tests"

class HammerProjectTest < Test::Unit::TestCase
  context "a hammer project" do
    setup do
      @hammer_project = Hammer::Project.new
    end
    
    context "when empty" do
      should "compile" do
        assert @hammer_project.compile()
        assert_equal @hammer_project.compile().length, 0
      end
    end
    
    context "with files" do
      
      setup do
        @header = Hammer::HammerFile.new
        @header.filename = "_header.html"
        @header.text = "header"
        @hammer_project = Hammer::Project.new
        @hammer_project << @header
        Hammer::HammerParser.any_instance.stubs(:parse).returns(@header.text)
      end
      
      should "compile and return hammer files" do
        assert @hammer_project.compile()
        assert_equal @hammer_project.compile().length, 1
        assert_equal @hammer_project.compile().first, @header
        assert_equal @hammer_project.compile().first.text, @header.text
      end
      
      should "find the right parser for a file" do
        assert_equal Hammer.parser_for(@header.extension), Hammer::HTMLParser
      end
      
    end
  end

  context "A Hammer project with files" do
    setup do
      @header = Hammer::HammerFile.new
      @header.filename = "_header.html"
      @header.text = "header"
      @hammer_project = Hammer::Project.new
      @hammer_project << @header
      @parser = Hammer::HTMLParser.new
    end

    should "test_finding_files_finds_the_right_file" do
      
      html_file = Hammer::HammerFile.new
      html_file.filename = "_not_header.html"
      @hammer_project << html_file
      
      new_file = Hammer::HammerFile.new
      new_file.filename = "_not_header.js"
      @hammer_project << new_file
      
      assert_equal @hammer_project.find_files('_not_header', @parser), [html_file]
      assert_equal @hammer_project.find_files('_not_header_1', @parser), []
      assert_equal @hammer_project.find_files('_not_header_1', @parser), []
      assert_equal @hammer_project.find_files('_not_header', new_file.parser.new), [new_file]
    end

    should "Find an array of files" do
      assert_equal @hammer_project.find_files('_header', @parser), [@header]
    end

    should "Find a file" do
      assert_equal @hammer_project.find_file('_header', @parser), @header
    end

  end
end