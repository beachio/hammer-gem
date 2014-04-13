#!/usr/bin/env ruby

require 'rake'
require 'test_helper'

class HammerParserTest < Test::Unit::TestCase

  context "A parser" do
    setup do
      @parser = Hammer::Parser.new
      assert @parser
    end

    should "parse" do
      assert_equal "", @parser.parse("")
    end
  end

end