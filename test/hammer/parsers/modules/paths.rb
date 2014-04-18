#!/usr/bin/env ruby
require "test_helper"
require 'hammer/parser'
require 'parsers/modules/paths'

class PathsTest < Test::Unit::TestCase

  context "A parser" do
    class PathsTestParser
      def parse(text)
        path_to text
      end
      include Hammer::Paths
    end

    setup do
      @object = PathsTestParser.new(:path => "about.html")
    end

    should "parse and optimize" do
      assert_equal 'testing.html', @object.parse('testing.html')
    end
  end
end