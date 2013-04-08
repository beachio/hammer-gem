#!/usr/bin/ruby

require "tests"

# require File.expand_path(File.join(__FILE__, '../../lib/amp.rb'))

def check(output, expected_output)
  if output.strip != expected_output.strip
    @build_success = false
    @error = "Expected \n  #{expected_output}, \ngot \n  #{output}"
    puts "Fail!"
    puts "Expected \n  #{expected_output}, \ngot \n  #{output}"
  end
end

def test(input, expected_output, filename="index.html")
  input = input.strip
  expected_output = expected_output.strip
  output = Amp.parse(input, filename, 'current')
  assert_equal expected_output, output
end

def test_adding_class(input, expected_output, number_of_characters_in_tag)
  output = Amp.add_class_to_tag(input, 'current', number_of_characters_in_tag)
  assert_equal expected_output, output
end
  

class HammerAppTemplateTest < Test::Unit::TestCase
  
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
    
    
    should "add current-parent classes" do
      
      # Test that blog/show.html adds a parent class to blog/index.html
      test "<a href='../index.html'></a>", "<a class='current-parent' href='../index.html'></a>", "blog/show.html"
      test "<a href='index.html'></a>", "<a class='current-parent' href='index.html'></a>", "blog/show.html"
      test "<a href='../../index.html'></a>", "<a class='current-parent' href='../../index.html'></a>", "blog/about/show.html"
      test "<li><a href='../../index.html'></a></li>", "<li class='current-parent'><a class='current-parent' href='../../index.html'></a></li>", "blog/about/show.html"
      
    end
    
  end

end



