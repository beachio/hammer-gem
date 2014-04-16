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

class HammerParserChainParseTest < Test::Unit::TestCase 

  context "some parsers that are chained together by extensions" do

    module ::Hammer
      class ParserOne < ::Hammer::Parser
        include ::Hammer::ExtensionMapper
        accepts :a
        returns_extension :b
        def parse(text)
          text.gsub('One', 'Two')
        end
      end

      class ParserTwo < ::Hammer::Parser
        include ::Hammer::ExtensionMapper
        accepts :b
        returns_extension :c
        def parse(text)
          text.gsub('Two', 'Three')
        end
      end
    end

    should "parse the set of parsers correctly" do
      @file = 'index.a'
      FileUtils.mkdir_p(@dir = Dir.mktmpdir)
      File.open(File.join(@dir, @file), 'w') do |f|; f.write "One"; end
      Hammer::Parser.parse_file(@dir, @file, true) do |output, data|
        assert_equal "Three", output
      end
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

      Hammer::Parser.parse_file(@dir, @file, true) do |output, data|
        assert_equal output, "Hi"
        assert data.is_a? Hash
      end
    end
  end
end