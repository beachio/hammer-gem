require "amp/amp"
require "test_helper"

def test(input, expected_output, filename="index.html")
  input = input.strip
  expected_output = expected_output.strip
  output = Amp.parse(input, filename, 'current')
  output = Amp.parse_for_current_parent(input, filename, 'current-parent')
  assert_equal expected_output, output
end

def test_adding_class(input, expected_output, number_of_characters_in_tag)
  output = Amp.add_class_to_tag(input, 'current', number_of_characters_in_tag)
  assert_equal expected_output, output
end

class AmpTest < Test::Unit::TestCase
  
  context "Amp" do
    
    should "only add the current class when told to" do
      tag = "<a class='a' href='index.html'></a>"
      test_adding_class tag, "<a class='current a' href='index.html'></a>", 1
    end
    
    should "add current class" do
      test "
        <!doctype html>
        <html>
          <head></head>
          <body>
            <ul><li></li></ul>
            Test data
            <a href='index.html'>This is some text here.</a>
          </body>
        </html>
      ", 
      "<!doctype html>
        <html>
          <head></head>
          <body>
            <ul><li></li></ul>
            Test data
            <a class='current' href='index.html'>This is some text here.</a>
          </body>
        </html>"

      test  "<li><a href='index.html'></a></li>", 
            "<li class='current'><a class='current' href='index.html'></a></li>"

      test  "<li><span></span><a href='index.html'></a></li>", 
            "<li class='current'><span></span><a class='current' href='index.html'></a></li>"

      test  "<ul><li><span></span><a href='index.html'></a></li></ul>",
            "<ul><li class='current'><span></span><a class='current' href='index.html'></a></li></ul>"

      test  "<ul><li><span></span><a href='index.html'></a></li></ul>",
            "<ul><li class='current'><span></span><a class='current' href='index.html'></a></li></ul>"

      test  "<html><body></body></html>",
            "<html><body></body></html>"

      test "<ul><li><a class='hats' href='index.html'>Testing 123</a></li></ul>", "<ul><li class='current'><a class='current hats' href='index.html'>Testing 123</a></li></ul>"

      test "<ul><li><a class href='index.html'>Testing 123</a></li></ul>", "<ul><li class='current'><a class='current' href='index.html'>Testing 123</a></li></ul>"

      test "<ul><li class='awesome'><a class='a' href='index.html'>Testing 123</a></li></ul>", "<ul><li class='current awesome'><a class='current a' href='index.html'>Testing 123</a></li></ul>"

      test "<ul><li class><a class='a' href='index.html'>Testing 123</a></li></ul>", "<ul><li class='current'><a class='current a' href='index.html'>Testing 123</a></li></ul>"

      test "<ul><li class><a class='a' href='index.html'>Testing 123</a></li> <li></li></ul> some text", "<ul><li class='current'><a class='current a' href='index.html'>Testing 123</a></li> <li></li></ul> some text"

      test "<link rel='stylesheet' type='text/css' href='index.html'>some text <a href='index.html'></a>", "<link rel='stylesheet' type='text/css' href='index.html'>some text <a class='current' href='index.html'></a>"

      test "<link rel='stylesheet' type='text/css' href='index.html' />
        <link rel='stylesheet' type='text/css' href='index.html' />
        <link rel='stylesheet' type='text/css' href='index.html' />
        <a href='index.html'></a><span> <a class='hat' href='index.html'></a> <span href='index.html'>",
        "<link rel='stylesheet' type='text/css' href='index.html' />
        <link rel='stylesheet' type='text/css' href='index.html' />
        <link rel='stylesheet' type='text/css' href='index.html' />
        <a class='current' href='index.html'></a><span> <a class='current hat' href='index.html'></a> <span href='index.html'>"


      test "<a href='index.html'></a><span> <a class='hat' href='index.html'></a> <span href='index.html'>", 
            "<a class='current' href='index.html'></a><span> <a class='current hat' href='index.html'></a> <span href='index.html'>"
      
      test "<a class='a' href='index.html'></a>", 
            "<a class='current a' href='index.html'></a>"
    end
    
    
      
      # Test that blog/show.html adds a parent class to blog/index.html
      
      # Root example
    should "not add current-parent classes to the root document" do
      test "<a href='../index.html'></a>", "<a href='../index.html'></a>", "blog/show.html"
    end
    
    should "add current-parent class to an index.html file in the same folder" do
      test "<a href='index.html'></a>", "<a class='current-parent' href='index.html'></a>", "blog/show.html"
    end
    
    should "add current-parent classes" do
      test "<a href='../index.html'></a>", "<a class='current-parent' href='../index.html'></a>", "blog/about/show.html"
    end
    
    should "add current-parent class to wrapping LIs" do
      test "<li><a href='../index.html'></a></li>", "<li class='current-parent'><a class='current-parent' href='../index.html'></a></li>", "blog/about/show.html"
    end
    should "not add current-parent class to the wrapping LI when linking to the project root" do
      test "<li><a href='../../index.html'></a></li>", "<li><a href='../../index.html'></a></li>", "blog/about/show.html"
    end
    
    should "add current-parent class to links to other files correctly" do
      text = %Q{
          <span><a href="../../index.html">Hammer Project</a></span>
          <span class="home"><a href="../index.html">Home</a></span>
          <span class="pages"><a href="#">Pages</a>
            <ul>
              <li><a href="../new.html">Added in 1.3<small>New</small></a></li>
              <li><a href="../start.html">Getting Started</a></li>
              <li><a href="../tags.html">Hammer Tags</a></li>
              <li><a href="../languages.html">Language Support</a></li>
              <li><a href="../editing.html">Editing &amp; Publishing</a></li>
              <li><a href="../optimize.html">Optimized Mode<small>New</small></a></li>
              <li><a href="../publishing.html">Publishing</a></li>
            </ul>
          </span>
        }
        output = %Q{
          <span><a href="../../index.html">Hammer Project</a></span>
          <span class="home"><a class='current-parent' href="../index.html">Home</a></span>
          <span class="pages"><a href="#">Pages</a>
            <ul>
              <li><a href="../new.html">Added in 1.3<small>New</small></a></li>
              <li><a href="../start.html">Getting Started</a></li>
              <li><a href="../tags.html">Hammer Tags</a></li>
              <li><a href="../languages.html">Language Support</a></li>
              <li><a href="../editing.html">Editing &amp; Publishing</a></li>
              <li><a href="../optimize.html">Optimized Mode<small>New</small></a></li>
              <li><a href="../publishing.html">Publishing</a></li>
            </ul>
          </span>
        }
        test text, output, "docs/tags/includes.html"
    end
    
    should "only tag the pages it relates to" do
      text = %Q{
        <a href="../../index.html"><b>Hammer</b> for Mac <em class="tag">1.5</em></a>
        <ul>
          <li><a href="../../index.html"><b>Features</b> <small>Take the tour</small></a></li>
          <li><a href="../../templates.html"><b>Templates <em class="tag">New</em></b> <small>Browse gallery</small></a></li>
          <li><a href="../index.html"><b>Docs</b> <small>Read up</small></a></li>
          <li><a href="../../news.html"><b>News &amp; Updates</b> <small>All the latest about Hammer</small></a></li>
        </ul>
        <ul>
          <li><a href="index.html">Overview</a></li>
          <li><a href="paths.html">Clever Paths</a></li>
          <li><a href="includes.html">HTML Includes</a></li>
          <li><a href="stylesheets.html">Stylesheets &amp; JavaScript</a></li>
          <li><a href="navigation.html">Navigation Helpers</a></li>
          <li><a href="variables.html">Variables</a></li>
          <li><a href="todos.html">Todos<span>New</span></a></li>
          <li><a href="placeholder.html">Image Placeholders<span>New</span></a></li>
          <li><a href="autoreload.html">Automatic Reload</a></li>
        </ul>
      }
      
      output = %Q{
        <a href="../../index.html"><b>Hammer</b> for Mac <em class="tag">1.5</em></a>
        <ul>
          <li><a href="../../index.html"><b>Features</b> <small>Take the tour</small></a></li>
          <li><a href="../../templates.html"><b>Templates <em class="tag">New</em></b> <small>Browse gallery</small></a></li>
          <li class='current-parent'><a class='current-parent' href="../index.html"><b>Docs</b> <small>Read up</small></a></li>
          <li><a href="../../news.html"><b>News &amp; Updates</b> <small>All the latest about Hammer</small></a></li>
        </ul>
        <ul>
          <li class='current-parent'><a class='current-parent' href="index.html">Overview</a></li>
          <li><a href="paths.html">Clever Paths</a></li>
          <li><a href="includes.html">HTML Includes</a></li>
          <li class='current'><a class='current' href="stylesheets.html">Stylesheets &amp; JavaScript</a></li>
          <li><a href="navigation.html">Navigation Helpers</a></li>
          <li><a href="variables.html">Variables</a></li>
          <li><a href="todos.html">Todos<span>New</span></a></li>
          <li><a href="placeholder.html">Image Placeholders<span>New</span></a></li>
          <li><a href="autoreload.html">Automatic Reload</a></li>
        </ul>

      }
      
      test text, output, "docs/tags/stylesheets.html"
    end
    
    should "only affect the affected elements" do
      text = %Q{
        <li><a href="../../news.html">News</a></li>
        <a href="../index.html">Home</a>
        <li><a href="index.html">Hammer Tags</a></li>
      }
      output = %Q{
        <li><a href="../../news.html">News</a></li>
        <a class='current-parent' href="../index.html">Home</a>
        <li class='current-parent'><a class='current-parent' href="index.html">Hammer Tags</a></li>
      }
      test text, output, "docs/tags/stylesheets.html"
    end
    
    should "style <li> tags" do
      text = %Q{
        <li><a href="index.html">Hammer Tags</a></li>
      }
      output = %Q{
        <li class='current-parent'><a class='current-parent' href="index.html">Hammer Tags</a></li>
      }
      test text, output, "docs/tags/stylesheets.html"
    end
    
  end

end



