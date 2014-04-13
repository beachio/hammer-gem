#!/usr/bin/env ruby
require "test_helper"
# require File.dirname(__FILE__) + '/test_helper'
require 'lib/hammer/parsers/extensions'

class ExtensionsTest < Test::Unit::TestCase

  class Thing
    include Hammer::ExtensionMapper
    returns_extension :thing
  end

  setup do
    @object = Thing.new
  end

  def test_registration_for_extensions
    assert @object.class.register_as_default_for_extensions(:thing)
    assert_equal [Thing], @object.class.for_extension(:thing)
  end

end

class ExtensionsChainTest < Test::Unit::TestCase

  module Hammer
    class ParserOne
      include ::Hammer::ExtensionMapper
      accepts :one
      returns_extension :two
    end

    class ParserTwo
      include ::Hammer::ExtensionMapper
      accepts :two
      returns_extension :three
    end
  end

  def test_for_extension_returns_parser_queue
    assert_equal [Hammer::ParserOne, Hammer::ParserTwo], Hammer::ParserOne.for_extension(:one)
  end

  def test_returns_last_extension
    assert_equal 'three', Hammer::ParserOne.final_extension_for(:one)
  end

end