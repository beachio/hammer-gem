#!/usr/bin/env ruby
require "test_helper"
require 'hammer/parser'
require 'parsers/modules/optimizer'

class VariablesTest < Test::Unit::TestCase

  context "A parser" do
    
    class OptimizerTestParser
      def parse(text)
        return text
      end
      include Hammer::Optimizer
    end

    setup do
      @object = OptimizerTestParser.new()
    end

    context "when optimized" do
      setup do
        @object.optimized = true
      end
      should "parse and optimize" do
        @object.expects(:optimize).once.with('text').returns('text (optimized)')
        assert @object.parse('text')
      end
    end

    context "when not optimized" do
      setup do
        @object.optimized = false
      end
      should "parse and not optimize" do
        @object.expects(:optimize).never
        assert @object.parse('text')
      end
    end
  end

end