#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
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

    should "needs_recompiling" do
      # @cacher.
    end
  end

end
