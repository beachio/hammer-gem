#!/usr/bin/env ruby

require 'test_helper'
require 'hammer/templates/base'

class HammerTemplateTest < Test::Unit::TestCase
  context "a template" do
    setup do
      @output = {'index.html' => {:filename => 'index.html', :output_filename => "index.html"}}
      @directory = Dir.mktmpdir

      @parser = Hammer::Template.new(@output, {:input_directory => @directory})
    end

    should "be successful" do
      assert @parser.success?
    end
  end
end

require 'hammer/templates/application'

class HammerApplicationTemplateTest < Test::Unit::TestCase
  context "an empty app template" do
    setup do
      @template = Hammer::ApplicationTemplate.new([])
    end

    should "have empty arrays for all its attributes" do
      assert_equal [], @template.send(:html_files)
      assert_equal [], @template.send(:compilation_files)
      assert_equal [], @template.send(:todo_files)
      assert_equal [], @template.send(:html_includes)
      assert_equal [], @template.send(:image_files)
      assert_equal [], @template.send(:ignored_files)
      assert_equal [], @template.send(:css_js_files)
      assert_equal [], @template.send(:error_files)
    end

    should "have 'no files' somewhere in its to_s" do
      assert @template.to_s.include? 'No files'
    end

    should "Create the right classes for a file" do
      # TODO: output_filename should be optional in a file JSON.
      def classes_for(filename)
        @template.span_class({:filename => filename, :output_filename => filename})
      end

      assert_equal 'html', classes_for('index.html')
      assert_equal 'css', classes_for('style.css')
      assert_equal 'png image', classes_for('style.png')

      assert @template.line_for({:filename => 'index.html', :output_filename => 'index.html'}).include? 'index.html'
    end
  end

  def template_with_files(files, &block)
    @template = Hammer::ApplicationTemplate.new(files)
    block.call(@template)
  end

  context "an empty app template" do

    setup do
      @files = {'index.html' => {:filename => "index.html", :output_filename => "index.html"}}
    end

    should "have HTML files" do
      template = Hammer::ApplicationTemplate.new(@files)
      assert_equal [@files['index.html']], template.send(:html_files)
      assert_equal [], template.send(:other_files)
    end

    should "have error files" do
      @files['index.html'][:error] = "An error!"
      template = Hammer::ApplicationTemplate.new(@files)
      assert_equal [@files['index.html']], template.send(:error_files)
      assert_equal [], template.send(:other_files)
    end

    should "have HTML includes" do
      @files['_index.html'] = {:filename => "_index.html", :output_filename => "_index.html"}
      template = Hammer::ApplicationTemplate.new(@files)
      assert_equal [@files['_index.html']], template.send(:html_includes)
      assert_equal [], template.send(:other_files)
    end

    should "have todo files" do
      @files['_index.html'] = {:filename => "_index.html", :output_filename => "_index.html", :messages => {1 => 'TODO: EVERYTHING', :html_class => 'todo'}}
      template = Hammer::ApplicationTemplate.new(@files)
      assert_equal [@files['_index.html']], template.send(:todo_files)
      assert_equal [], template.send(:other_files)
    end

    should "have css_js_files" do
      @files['index.js'] = {:filename => "index.js", :output_filename => "index.js", :messages => {1 => 'TODO: EVERYTHING', :html_class => 'todo'}}
      template = Hammer::ApplicationTemplate.new(@files)
      assert_equal [@files['index.js']], template.send(:css_js_files)
      assert_equal [], template.send(:other_files)
    end
  end
end