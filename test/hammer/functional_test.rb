require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'

class FunctionalTest < Test::Unit::TestCase
  
  def setup
    @options = {
      :input_directory => Dir.mktmpdir,
      :output_directory => Dir.mktmpdir,
      :cache_directory => Dir.mktmpdir
    }
    
    @options.values.each do |path|
      FileUtils.mkdir_p(path)
    end
  end

  def teardown
    @options.values.each do |path|
      FileUtils.rm_rf(path)
    end
  end

  def test_functional_projects
    directories = functional_test_directories

    directories.each do |directory|
      test_input_directory = File.join directory, 'input'
      test_output_directory = File.join directory, 'output'
      
      FileUtils.rm_rf @options[:input_directory]
      FileUtils.rm_rf @options[:output_directory]
      FileUtils.rm_rf @options[:cache_directory]

      FileUtils.mkdir_p @options[:input_directory]
      FileUtils.mkdir_p @options[:output_directory]
      FileUtils.mkdir_p @options[:cache_directory]

      FileUtils.cp_r Dir[File.join(test_input_directory, "*")], @options[:input_directory] rescue true

      build = Hammer::Build.new @options
      build.compile

      errors = build.project.hammer_files.collect(&:error).compact
      assert_equal [], errors

      # assert Dir.exists? @options[:output_directory]
      compare_directories test_output_directory, @options[:output_directory]
    end
  end

  def compare_directories a, b
    _compare_directories(a, b)
    _compare_directories(b, a)
  end

  def _compare_directories a, b
    a_files = Dir.glob(File.join(a, "**/*"))
    b_files = Dir.glob(File.join(b, "**/*"))
    
    a_files.each do |a_file_path|
      
      relative_file_path = Pathname.new(a_file_path).relative_path_from(Pathname.new(a))
      b_file_path = File.join(b, relative_file_path)
      
      assert File.exist?(b_file_path), "File missing: #{a_file_path} wasn't compiled to Build folder"

      if !File.directory? a_file_path    
        match = FileUtils.compare_file(b_file_path, a_file_path)
        if !match
          puts "File: #{a_file_path}:"
          puts "#{File.open(a_file_path).read}"
          puts "File: #{b_file_path}"
          puts "#{File.open(b_file_path).read}"
        end
        assert match, "Files #{b_file_path} and #{a_file_path} don't match!"
      end
    end
  end
end