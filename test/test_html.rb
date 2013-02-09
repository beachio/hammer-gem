class HTMLParserTest < Test::Unit::TestCase
  def setup
    @hammer_project       = Hammer::Project.new
    @file                 = Hammer::HammerFile.new
    @hammer_project << @file
    @file.hammer_project  = @hammer_project
    @parser               = Hammer::HTMLParser.new(@hammer_project)
    @parser.hammer_file   = @file
  end

  def test_reload_tags
    @parser.text = "<html><!-- @reload --></html>"
    assert !@parser.parse().include?("@reload/<!-- @reload -->/")
  end

  def test_includes
    header = Hammer::HammerFile.new
    header.filename = "_header.html"
    header.text = "header"
    header.expects(:to_html).returns("header")
    @hammer_project << header

    @parser.text = "<html><!-- @include _header --></html>"
    @hammer_project.expects(:find_file).returns(header)
    
    assert_equal "<html>header</html>", @parser.parse()
  end
end