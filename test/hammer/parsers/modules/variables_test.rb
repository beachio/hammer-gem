#!/usr/bin/env ruby
require "test_helper"
require 'lib/hammer/parser'
require 'lib/hammer/parsers/modules/variables'

class VariablesTest < Test::Unit::TestCase

  context "A parser" do
    setup do
      class VariablesTestParser < Hammer::Parser
        include Hammer::Variables
      end
      @object = VariablesTestParser.new
    end

    should "be able to set variables" do
      @object.send :set_variable, 'working', 'true'
      assert_equal({'working' => 'true'}, @object.variables)
    end

    should "be able to get variables" do
      @object.send :set_variable, 'working', 'true'
      assert_equal @object.send(:get_variable, 'working'), 'true'
    end
  end

end