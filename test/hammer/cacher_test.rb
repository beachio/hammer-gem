#!/usr/bin/env ruby
require File.join File.dirname(__FILE__), '..', 'test_helper'
require File.join File.dirname(__FILE__), 'test_helper'
# require './test_helper'
require 'hammer/cacher'

class ProjectCacherTest < Test::Unit::TestCase
  
  context "A cacher" do
    setup do
      @cacher = Hammer::ProjectCacher.new
    end

    def teardown
      
    end

    should "be a cacher" do
      assert @cacher
    end

    context "with files stubbed out" do
      setup do
        @cacher.stubs(:find_files).returns([])
        @cacher.stubs(:hammer_files).returns([])
      end 

      should "add wildcard dependency" do
        assert @cacher.add_wildcard_dependency('index.html', 'about', 'html')
      end

      should "add file dependency" do
        @cacher.set_cached_contents_for('about/parent.html', '<h1>Hello</h1>')
        assert @cacher.add_file_dependency('about/parent.html', 'about/child.html')
        assert @cacher.valid_cache_for('about/parent.html')
      end
    end

    should "store the cache" do
      @cacher.set_cached_contents_for('index.html', '<h1>Hello</h1>')
      assert_equal @cacher.cached_contents_for('index.html'), '<h1>Hello</h1>'
      assert @cacher.valid_cache_for('index.html')
    end

    context "with a directory" do
      setup do
        @directory = Dir.mktmpdir
        File.open(File.join(@directory, 'index.html'), 'w') do |f|
          f.puts "Testing"
        end
        @cacher.input_directory = @directory
        @cacher.read_from_disk
        @cacher.create_hashes
        assert !@cacher.valid_cache_for('index.html')
        @cacher.write_to_disk
      end

      should "have valid caches when the file hasn't changed" do
        @cacher.read_from_disk
        assert !@cacher.send(:file_changed, 'index.html')
      end

      should "have valid caches when the file HAS changed" do
        File.open(File.join(@directory, 'index.html'), 'w') do |f|
          f.puts "Testing 123"
        end
        @cacher.set_cached_contents_for 'index.html', 'Testing 123'
        assert @cacher.needs_recompiling?('index.html')
      end
    end
  end

end
