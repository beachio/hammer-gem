#!/usr/bin/env ruby
require 'test_helper'
require 'hammer/templates/base'

class TemplateTest < Test::Unit::TestCase

  setup do
    @template = Hammer::BaseTemplate.new
  end

  def who_tests_the_tests
    assert @template
  end

  test "No to_s on the base template" do
    assert_raises RuntimeError do
      @template.to_s
    end
  end

end
