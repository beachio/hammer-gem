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
        assert @cacher.add_file_dependency('about/parent.html', 'about/child.html')
        assert !@cacher.needs_recompiling?('about/parent.html')
      end
    end

    should "store the cache" do
      @cacher.set_cached_contents_for('index.html', '<h1>Hello</h1>')
      assert_equal @cacher.cached_contents_for('index.html'), '<h1>Hello</h1>'
      assert !@cacher.needs_recompiling?('index.html')
    end
  end

end
