#!/usr/bin/env ruby
require "test_helper"
require 'lib/hammer/parser'
require 'lib/hammer/parsers/modules/file_adder'

class VariablesTest < Test::Unit::TestCase

  context "A parser" do
    setup do
      class FileAddingTestParser < Hammer::Parser
        include Hammer::FileAdding

        def parse(text)
          add_file('created.html', 'Created!')
          return text
        end
      end

      @object = FileAddingTestParser.new
      @object.directory = Dir.mktmpdir
    end

    should "be able to create a file" do
      @object.parse('text')
      assert @object.to_hash[:added_files].keys.include? 'created.html'
      contents = File.open(@object.to_hash[:added_files]['created.html']).read
      assert_equal contents, 'Created!'
      assert File.exist? File.join(@object.output_directory, 'created.html')
    end
  end

end