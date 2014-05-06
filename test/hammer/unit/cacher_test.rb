#!/usr/bin/env ruby

require '../test_helper' unless defined?(Hammer)
require 'rake'
require 'tmpdir'
require 'hammer'
require 'hammer/cacher'

# A cacher object for a Hammer project.
# Takes project-wide dependencies, and wildcard dependnecies

# Dependencies:
# {'index.html' => ['about.html']}

# Wildcard Dependencies:
# {'index.html' => {'about' => ['about.html']}

class CacherTest < Test::Unit::TestCase

  context "A cacher" do

    setup do
      @input_directory = Dir.mktmpdir
      @output_directory = Dir.mktmpdir
      @cache_directory = Dir.mktmpdir

      @dependencies = {}
      @wildcard_dependencies = {}

      @object = Hammer::Cacher.new(@input_directory, @cache_directory, @output_directory)
    end

    teardown do
      FileUtils.rm_rf @input_directory
      FileUtils.rm_rf @output_directory
      FileUtils.rm_rf @cache_directory
    end

    # should "return false if checking the caching of an object" do
    #   assert !@object.cached?('index.html')
    # end

    context "having cached a file" do
      setup do
        @file = File.join(@input_directory, 'index.html')
        File.open(@file, 'w') { |f| f.puts "Input" }
        @object.cache('index.html', @file)
        @object.write_to_disk
        @object = Hammer::Cacher.new(@input_directory, @cache_directory, @output_directory)
      end

      should "have a valid cache" do
        assert @object.cached?('index.html')
      end

      should "have a valid cache until the file is changed" do
        File.open(@file, 'w') { |f| f.puts "Modified Input" }
        assert !@object.cached?('index.html')
      end
    end

    # context "with two files" do
    #   setup do
    #     @this_file = File.join(@input_directory, 'index.html')
    #     @other_file = File.join(@input_directory, 'about.html')
    #     File.open(@this_file, 'w') do |file|; file.puts("A"); end
    #     File.open(@other_file, 'w') do |file|; file.puts("B"); end
    #   end
    #   context "with dependencies" do
    #     setup do
    #       @object.dependencies = {'index.html' => ['about.html']}
    #       @object.cache('index.html', @this_file)
    #     end

    #     should "have a cache if the other file is cached too" do
    #       assert !@object.cached?('index.html')
    #       @object.cache('about.html', @other_file)
    #       assert @object.cached?('index.html')
    #     end
    #   end

    #   context "with wildcard dependencies" do
    #     setup do
    #       @object.wildcard_dependencies = {'index.html' => {'about' => ['about.html']}}
    #       @object.cache('index.html', @this_file)
    #     end

    #     should "have a cache of this file" do
    #       assert @object.cached?('index.html')
    #     end
    #   end
    # end
  end
end