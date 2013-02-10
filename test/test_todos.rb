require "./tests.rb"

class TestTodos < Test::Unit::TestCase
  
  context "multiple comments on one line" do
    formats = {
      'html' => '<!-- @todo eat --><!-- @todo cake -->'
    }
    
    parser = Hammer::TodoParser
    
    formats.each do |format, comment|
      context "With #{format}" do
        setup do
          @parser = parser.new(comment, format)
        end
        should "replace todos with empty string" do
          assert_equal "", @parser.text
        end
        should "set todos for #{comment}" do
          assert_equal({1 => ['eat', 'cake']}, @parser.todos)
        end
      end
    end
    
  end
  
  context "on one line" do
    
    formats = {
      'html' => '<!-- @todo eat -->',
      'js' => '/* @todo eat */',
      'js' => '// @todo eat',
      'css' => '/* @todo eat */',
      'scss' => '/* @todo eat */',
      'sass' => '/* @todo eat */',
      'sass' => '/* @todo eat */',
      'coffee' => '# @todo eat'
    }
    
    parser = Hammer::TodoParser
    
    formats.each do |format, comment|
      context "With #{format}" do
        setup do
          @parser = parser.new(comment, format)
        end
        should "replace todos with empty string" do
          assert_equal "", @parser.text
        end
        should "set todos for #{comment}" do
          assert_equal({1 => ['eat']}, @parser.todos)
        end
      end
    end
  end
end