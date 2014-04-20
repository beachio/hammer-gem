#!/usr/bin/env ruby
require "test_helper"
require 'parsers/modules/dependency'

class DependencyTest < Test::Unit::TestCase

  module Hammer
    class ParserOne
      include ::Hammer::Dependency
    end
  end

  setup do
    @parser = Hammer::ParserOne.new # (:path => "index.html", :directory => Dir.mktmpdir)
    @directory = Dir.mktmpdir
  end

  def test_adding_a_single_dependency
    @parser.send(:add_dependency, 'include.html')
    assert_equal ['include.html'], @parser.dependencies
  end

  def test_add_wildcard_dependency
    @parser.expects(:find_files).with('include', 'html').returns(['include.html'])
    @parser.send(:add_wildcard_dependency, 'include', 'html')
    assert_equal({'include' => ['include.html']}, @parser.wildcard_dependencies)
  end

  def test_find_files
    # file = Dir.join(@directory, 'index.html')
    path = 'include.html'
    @parser.expects(:find_files).with('include', 'html').returns(path).at_least_once

    @parser.send :find_files_with_dependency, 'include', 'html'
    assert_equal({'include' => ['include.html']}, @parser.wildcard_dependencies)
  end

end