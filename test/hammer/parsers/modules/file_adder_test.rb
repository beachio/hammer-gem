#!/usr/bin/env ruby
require "test_helper"
require 'hammer/parser'
require 'parsers/modules/adding_files'

class VariablesTest < Test::Unit::TestCase

  context "A parser" do
    setup do
      class AddingFilesTestParser < Hammer::Parser
        include Hammer::AddingFiles

        def parse(text)
          add_file('created.html', 'Created!', ['one.html', 'two.html'])
          return text
        end
      end

      @object = AddingFilesTestParser.new
      @object.directory = Dir.mktmpdir('input_directory')
      @object.input_directory = @object.directory
      @object.output_directory = Dir.mktmpdir('output_directory')
    end

    should "be able to create a file" do
      @object.parse('text')

      assert_equal ['one.html', 'two.html'], @object.added_files[0][:filenames]
      assert_equal 'created.html', @object.added_files[0][:filename]

      created_file = File.join(@object.output_directory, 'created.html')
      assert File.exist?(created_file)
      assert_equal File.open(created_file).read, 'Created!'
    end
  end

end