#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'hammer/project_cacher'

class ProjectCacherTest < Test::Unit::TestCase
  
  def setup
    @cacher = Hammer::ProjectCacher.new
  end

  def teardown
    
  end

  def test_cacher
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
      # assert !@cacher.needs_recompiling?('about/parent.html')
    end
  end

end
