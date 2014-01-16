#!/usr/bin/env ruby
require 'test_helper'
require 'hammer/templates/application'

class ApplicationTemplateTest < Test::Unit::TestCase

  setup do
    @project = Hammer::Project.new
    @template = Hammer::ApplicationTemplate.new(:project => @project)
  end

  def who_tests_the_tests
    assert @template
  end

  test "to_s" do
    @template.to_s
  end

  def test_successful_build(text)
    text = text.to_s
    assert text.include? "There are no errors in your project"
  end


  context "with files" do
    setup do
      directory = File.join(File.dirname(functional_test_directories.first), 'html')
      @project = Hammer::Project.new(:input_directory => directory)
      @project.read()
      assert @project.hammer_files.length > 0
      @template.project = @project
    end

    should "not have an error" do
      puts @template
      # test_successful_build @template
    end
  end

  test "should not have any files" do
    text = @template.to_s
    assert text.include? "No files to build"
  end

end
