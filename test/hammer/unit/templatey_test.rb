# Templatey is a small Template class used for handling template stuff in ERB.
# So far, h() is just a shortcut for CGI.escapeHTML.

require 'templatey'

class TemplateyTest < Test::Unit::TestCase
  class Thing
    include Templatey
  end
  def test_templatey_works
    thing = Thing.new
    assert_equal "&lt;3", thing.h('<3')
  end
end