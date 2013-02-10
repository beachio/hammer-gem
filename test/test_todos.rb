require "./tests.rb"

class TestTodos < Test::Unit::TestCase
  formats = {
    'html' => '<!-- @todo eat -->'
  }
  
  parser = Hammer::TodoParser
  
  formats.each do |format, comment|
    context "With #{format}" do
      setup do
        @parser = parser.new(comment, format)
      end
      should "replace todos with empty string" do
        assert_equal @parser.text, ""
      end
      should "set todos" do
        assert_equal @parser.todos, {1 => 'eat'}
      end
    end
  end
end