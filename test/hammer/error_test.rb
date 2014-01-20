require File.join File.dirname(__FILE__), 'test_helper'
require 'hammer/error'

class ErrorTest < Test::Unit::TestCase
  should "create from an error" do
    e = RuntimeError.new
    file = Hammer::HammerFile.new(:filename => "index.html")
    @error = Hammer::Error.from_error(e, file)
    assert_equal @error.original_error, e
    assert_equal @error.hammer_file, file
  end
end