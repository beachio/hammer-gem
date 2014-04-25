#!/usr/bin/env ruby

require 'test_helper'
require 'hammer/templates/base'

class HammerTemplateTest < Test::Unit::TestCase

  context "a template" do
    setup do
      @output = {'index.html' => {:filename => 'index.html', :output_filename => "index.html"}}
      @directory = Dir.mktmpdir

      @parser = Hammer::Template.new(@output, @directory)
    end

    should "be successful" do
      assert @parser.success?
    end
  end


end