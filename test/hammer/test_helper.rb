require File.dirname(__FILE__) + '/../test_helper'

def functional_test_directories
  Dir.glob(File.join(File.dirname(__FILE__), 'functional', '*'))
end