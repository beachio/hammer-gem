#!/usr/bin/env ruby
require "test_helper"
require 'lib/hammer/parser'
require 'lib/hammer/parsers/modules/replacement'

class ReplacementTest < Test::Unit::TestCase

  context "A parser" do
    class ReplacementTestParser
      def parse(text)
        replace(text, /yes/) do |tag, line_number|
          "no"
        end
      end
      include Hammer::Replacement
    end

    setup do
      @object = ReplacementTestParser.new()
    end

    should "parse and optimize" do
      assert_equal 'no no no', @object.parse('yes yes yes')
    end
  end
end