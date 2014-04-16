#!/usr/bin/env ruby

require 'test_helper'
require 'lib/hammer/parser'

class HammerParserTest < Test::Unit::TestCase

  context "A parser" do
    setup do
      @parser = Hammer::Parser.new
    end

    should "parse an empty string" do
      assert_equal "", @parser.parse("")
    end

    should "be able to be optimized" do
      assert @parser.optimized = true
    end
  end

end

class HammerParserDataTest < Test::Unit::TestCase

  context "a parser" do
    setup do
      @object = Hammer::Parser.new
    end

    should "serialize variables using to_hash and from_hash" do
      json = {:variables => {'test' => 'success'}}

      assert @object.from_hash(json)
      assert_equal json[:variables], @object.to_hash[:variables]
    end
  end

end

class HammerParserClassMethodsTest < Test::Unit::TestCase
  context "a file" do
    setup do
      @dir = Dir.mktmpdir
      @file = 'index.html'

      FileUtils.mkdir_p(@dir)
      File.open(File.join(@dir, @file), 'w') do |f|
        f.write "Hi"
      end
    end

    should "be parsed using a block" do

      Hammer::Parser.parse_file(@dir, File.join(@dir, @file), true) do |output, data|
        assert_equal output, "Hi"
        assert data.is_a? Hash
      end

    end
  end
end