#!/usr/bin/env ruby

require 'test_helper'
require 'hammer/parser'

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
        include ::Hammer::Extensions
        accepts :a
        returns :b
        def parse(text)
          text.gsub('One', 'Two')
        end
      end

      class ParserTwo < ::Hammer::Parser
        include ::Hammer::Extensions
        accepts :b
        returns :c
        def parse(text)
          text.gsub('Two', 'Three')
        end
      end
    end

    should "parse the set of parsers correctly" do
      @file = 'index.a'
      @output_dir = Dir.mktmpdir
      FileUtils.mkdir_p(@dir = Dir.mktmpdir)
      File.open(File.join(@dir, @file), 'w') do |f|; f.write "One"; end
      Hammer::Parser.parse_file(@dir, @file, @output_dir, true) do |output, data|
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
      Hammer::Parser.parse_file(@dir, @file, Dir.mktmpdir, true) do |output, data|
        assert_equal output, "Hi"
        assert data.is_a? Hash
      end
    end
  end
end

module Hammer
  class ErrorParser < Parser
    def parse(text)
      # Setting error_line and raising is the way we report errors.
      # Should this have a new method? raise_error message, line?
      @error_line = 1
      raise "This is a simulated error."
    end
  end
end

# Test that the parse_file class method correctly returns data[:error]
# data = {:error => "This message was sent from the compiler."}
class HammerParserErrorsTest < Test::Unit::TestCase
  context "A parser that raises an error" do
    setup do
      dir = Dir.mktmpdir
      file = create_file 'index.html', 'Content', dir
      Hammer::Parser.any_instance.stubs(:parse).raises("Nothing")
      Hammer::Parser.parse_file(dir, 'index.html', Dir.mktmpdir, false) do |output, data|
        assert_equal "Nothing", data[:error]
      end
    end
  end
end

# class HammerParserErrorsTest < Test::Unit::TestCase

#   context "A parser that raises an error" do
#     setup do
#       @parser = Hammer::Parser.new(:path => "index.html")
#       @parser.stubs(:parse).raises("A simulated error")
#     end

#     should "raise an error on parse" do
#       assert_raise do
#         @parser.parse("never seen again")
#       end
#       assert_equal @parser.data[:error], "A simulated error"
#     end
#   end

# end