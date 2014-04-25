require 'erb'
require 'ostruct'
require 'templatey'
require 'toerb'

class Template
  attr_accessor :files

  def sort_files(files)
    return [] if files.nil?
    # This sorts the files into the correct order for display
    files.sort_by { |path, file|
      extension = File.extname(file[:output_filename]).downcase
      file[:filename]
    }.sort_by {|path, file|
      (file.include? :from_cache) ? 1 : 0
    }.sort_by {|path, file|
      file[:messages].to_a.length > 0 ? 0 : 1
    }.sort_by {|path, file|
      (file[:filename] == "index.html") ? 0 : 1
    }.sort_by {|path, file|
      file[:is_include?] ? 1 : 0
    }
  end

  def initialize(files, output_directory)
    # ['index.html' => {}, ...]
    @files = sort_files(files)
    # [{}, {}]
    @files = @files.map {|path, data| data }

    @output_directory = output_directory
  end

  def success?
    @files != nil and @files.length > 0 and @files.select {|path, file| file[:error]} == []
  end

private

  def total_errors
    error_files.length rescue 0
  end

  def total_todos
    files.collect(&:messages).flatten.compact.length
  end

  def html_includes
    files_of_type(['.php', '.html']).select {|file|
      File.basename(file[:output_filename]).start_with?("_") && !file[:error]
    }.compact
  end

  def todo_files
    files.select {|file|
      file[:messages].to_a.length > 0
    }.compact
  end

  def error_files
    files.select {|file|
      file[:error]
    }.compact.sort_by{|file|
        (file[:error] && file[:error][:hammer_file] != path) ? 100 : 10
    }.compact
  end

  def html_files
    files_of_type(['.html', '.php']).select { |file|
      !file[:error]
    }.compact
  end

  def compilation_files
    files.select {|file|
      file[:is_a_compiled_file] # && file.source_files.collect(&:error) == []
    }.compact
  end

  def css_js_files
    files_of_type(['.css', '.js']).select {|file|
      !file[:is_a_compiled_file]
    }.compact
  end

  def image_files
    files_of_type ['.png', '.gif', '.svg', '.jpg', '.gif']
  end

  def error
    nil
  end

  def other_files
    files - image_files - css_js_files - compilation_files - html_files - error_files
  end

  def ignored_files
    # TODO: Ignored files in the template
    []
  end

  def files_of_type(extension)
    extensions = [*extension]
    files.select {|file| extensions.include? File.extname(file[:output_filename])}.compact
  end
end