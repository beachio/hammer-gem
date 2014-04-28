require 'test_helper'
require 'capture'

class TestCapture < Test::Unit::TestCase
  def test_captures_puts
    a = capture_stdout do
      puts "Testing"
    end
    assert_equal a.string, "Testing\n"
  end
end