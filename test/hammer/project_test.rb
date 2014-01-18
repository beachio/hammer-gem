#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'hammer/project'

class ProjectTest < Test::Unit::TestCase
  
  def setup
    @options = {
      :input_directory => Dir.mktmpdir,
      :output_directory => Dir.mktmpdir,
      :cache_directory => Dir.mktmpdir
    }
    @options.values.each do |path|
      FileUtils.mkdir_p(path)
    end
    @project = Hammer::Project.new(@options)
  end

  def teardown
    @options.values.each do |path|
      FileUtils.rm_rf(path)
    end
  end

  def test_creating_a_project
    assert @project
  end

  def test_a_project_reads_its_files
    index_file = File.join(@options[:input_directory], 'index.html')
    FileUtils.touch(index_file)

    @project.read()
    assert_equal 1, @project.hammer_files.length
  end

  def test_a_project_doesnt_read_git_folders
    ['.git', '.svn'].each do |path|
      path_file = File.join(@options[:input_directory], path, 'myfile.html')
      FileUtils.mkdir_p File.dirname(path_file)
      FileUtils.touch(path_file)
    end

    assert_equal @project.hammer_files.length, 0
  end

  def test_a_project_compiles
    assert @project.compile()
  end

  def test_find_files
    file = Hammer::HammerFile.new(:filename => "style.css")
    @project << file
    assert_equal @project.find_file('style.css'), file
    assert_equal @project.find_files('style.css'), [file]
  end

  def test_find_files_with_paths
    file = Hammer::HammerFile.new(:filename => "assets/style.css")
    @project << file
    assert_equal @project.find_file('style.css'), file
    # assert_equal @project.find_file('sets/style.css'), file
  end

  def test_find_files_with_filenames
    file = Hammer::HammerFile.new(:filename => "assets/style.scss")
    @project << file
    assert_equal @project.find_file('style.css'), file
    # assert_equal @project.find_file('sets/style.css'), file
  end

  def test_find_files_with_filenames_two
    file1 = Hammer::HammerFile.new(:filename => "style.scss")
    @project << file1
    file2 = Hammer::HammerFile.new(:filename => "assets/style.scss")
    @project << file2
    assert_equal @project.find_file('style.css'), file1
    # assert_equal @project.find_file('sets/style.css'), file2
  end

  def test_caching_works_correctly
    index_file = File.join(@project.input_directory, 'index.html')
    File.open(index_file, 'w') do |f|; f.puts("a"); end
    files = @project.compile()
    file = files[0]

    project2 = Hammer::Project.new(@options)
    files2 = project2.compile()
    file2 = files2[0]

    assert file2.from_cache
  end

end