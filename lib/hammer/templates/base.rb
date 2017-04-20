require 'erb'
require 'ostruct'
require 'templatey'
require 'toerb'

module Hammer
  class Template
    attr_accessor :files, :error

    def sort_files(files)
      return [] if files.nil?
      # This sorts the files into the correct order for display
      files.sort_by { |path, file|
        filename = file[:output_filename] || ""
        extension = File.extname(filename).downcase
        file[:filename].to_s
      }.sort_by {|path, file|
        (file.include? :from_cache) ? 1 : 0
      }.sort_by {|path, file|
        file[:messages].to_a.length > 0 ? 0 : 1
      }.sort_by {|path, file|
        (file[:filename] == "index.html") ? 0 : 1
      }.sort_by {|path, file|
        file[:is_include?] ? 1 : 0
      }.sort_by {|path, file|
        full_path = File.join(@input_directory.to_s, file[:filename])
        if File.exist? full_path
          0 - File.mtime(full_path).to_i
        else
          0
        end
      }
    end

    def initialize(files, options={})
      @input_directory = options[:input_directory]
      @output_directory = options[:output_directory]
      
      @generated_files = files.delete(:generated)

      @files = sort_files(files) # ['index.html' => {}, ...]
      @files = @files.map {|path, data| data } # [{}, {}]
      @files = @files.compact
    end

    def success?
      error_files.length == 0
    end

  private

    def html_includes
      files_of_type(['.php', '.html']).select {|file|
        File.basename(file[:output_filename]).start_with?("_") && !file[:error]
      }.compact
    end

    def todo_files
      files.select {|file|
        file[:messages].to_a.length > 0
      }.compact - ignored_files
    end

    def error_files
      files.select {|file|
        file[:error]
      }.compact.sort_by{|file|
          (file[:error] && file[:error_file] != file[:filename]) ? 100 : 10
      }.compact - ignored_files
    end

    def html_files
      files_of_type(['.html', '.php']).select { |file|
        !file[:error] && !File.basename(file[:filename]).start_with?("_")
      }.compact - ignored_files
    end

    def compilation_files
      files.select {|file|
        file[:is_a_compiled_file] # && file.source_files.collect(&:error) == []
      }.compact - ignored_files
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
      @error
    end

    def missing?
      !File.exist? @input_directory
    end

    def other_files
      files - image_files - css_js_files - compilation_files - html_files - error_files - html_includes - ignored_files
    end

    def ignored_files
      # TODO: Ignored files in the template
      files.select {|file| file[:ignored]} || []
    end

    def contentful_files
      @generated_files[:contentful] || []
    end

    def cockpit_files
      @generated_files[:cockpit] || []
    end

    def chisel_files
      @generated_files[:chisel] || []
    end

    def files_of_type(extension)
      extensions = [*extension]
      @files.select {|file| extensions.include? File.extname(file[:output_filename])}.compact - ignored_files
    end
  end
end