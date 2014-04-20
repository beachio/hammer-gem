require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'

class FunctionalTest < Test::Unit::TestCase
  
  def setup
    @options = {
      :input_directory => Dir.mktmpdir,
      :output_directory => Dir.mktmpdir,
      :cache_directory => Dir.mktmpdir
    }
    
    create_directories()
  end

  def create_directories
    teardown()
    @options.values.each do |path|
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end
  end

  def teardown
    @options.values.each do |path|
      FileUtils.rm_rf(path)
    end
  end

  def functional_test_directories
    Dir.glob(File.join(File.  dirname(__FILE__), 'functional', '*'))
  end

  def test_functional_projects
    directories = functional_test_directories

    directories.each do |directory|

      test_input_directory = File.join directory, 'input'
      test_output_directory = File.join directory, 'output'
      optimized_output_directory = File.join directory, 'optimized_output'
      
      create_directories()

      FileUtils.mkdir @options[:input_directory] rescue true
      FileUtils.cp_r Dir[File.join(test_input_directory, "*")], @options[:input_directory]
      build = Hammer::Build.new @options

      build.compile()

      # errors = build.project.hammer_files.collect(&:error).compact
      errors = []
      assert_equal [], errors
      compare_directories test_output_directory, @options[:output_directory]

      # if File.exist? optimized_output_directory

      #   create_directories()
        
      #   FileUtils.mkdir @options[:input_directory] rescue true
      #   FileUtils.cp_r Dir[File.join(test_input_directory, "*")], @options[:input_directory]
      #   optimized_options = @options.merge({:optimized => true})
      #   build = Hammer::Build.new optimized_options
      #   puts build.compile()

      #   # errors = build.project.hammer_files.collect(&:error).compact
      #   assert_equal [], errors
      #   compare_directories optimized_output_directory, @options[:output_directory]        
      # end

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

      next if File.basename(a_file_path).start_with? '_'
      
      exists = File.exist?(b_file_path)
      assert exists, "File missing: #{a_file_path} wasn't compiled to Build folder (#{b_file_path})"

      if !File.directory? a_file_path    
        match = FileUtils.compare_file(b_file_path, a_file_path)
        if !match
          puts "File: #{a_file_path}:"
          puts "#{File.open(a_file_path, 'r:UTF-8').read}"
          puts "File: #{b_file_path}"
          puts "#{File.open(b_file_path, 'r:UTF-8').read}"
        end
        assert match, "Files #{b_file_path} and #{a_file_path} don't match!"
      end
    end
  end
end