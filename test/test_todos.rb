require "tests"

class TestTodos < Test::Unit::TestCase
  
  context "multiple comments on one line" do
    formats = {
      'html' => '<!-- @todo eat --><!-- @todo cake -->'
    }
    
    parser = Hammer::TodoParser
    
    formats.each do |format, comment|
      context "With #{format}" do
        setup do
          hammer_file = Hammer::HammerFile.new(:filename => "index.#{format}")
          hammer_file.raw_text = formats[format]
          @parser = parser.new(nil, hammer_file)
        end
        should "set todos for #{comment}" do
          assert_equal({1 => ['eat', 'cake']}, @parser.parse())
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
          hammer_file = Hammer::HammerFile.new(:filename => "index.#{format}")
          hammer_file.raw_text = formats[format]
          @parser = parser.new(nil, hammer_file)
        end
        should "set todos for #{comment}" do
          assert_equal({1 => ['eat']}, @parser.parse())
        end
      end
    end
  end
end