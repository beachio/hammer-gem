require File.dirname(__FILE__) + '/../test_helper'

module AssertCompilation
  def assert_compilation(pre, post)
    @parser.text = pre
    assert_equal post, @parser.parse()
  end
end
