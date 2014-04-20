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
          add_file('created.html', 'Created!')
          return text
        end
      end

      @object = AddingFilesTestParser.new
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