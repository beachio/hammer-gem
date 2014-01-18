require 'hammer/project'
require 'hammer/file'

module Hammer
  
  class BaseTemplate

    attr_accessor :files
    attr_accessor :project

    def initialize(options={})
      @project = options.delete(:hammer_project) if options[:hammer_project]
    end

    def files
      files = @project.hammer_files
      return [] if files.nil?
      # This sorts the files into the correct order for display
      @sorted_files ||= files.sort_by { |file|
        extension = File.extname(file.output_filename).downcase
        file.filename
      }.sort_by {|file|
        file.from_cache ? 1 : 0
      }.sort_by {|file|
        file.messages.length > 0 ? 0 : 1
      }.sort_by {|file|
        (file.filename == "index.html") ? 0 : 1
      }.sort_by {|file|
        file.include? ? 1 : 0
      }
    end
    
    def success?
      @files != nil and @files.length > 0 and @files.select {|file| file.error} == []
    end
    
    def to_s; raise "No such method: to_s in Hammer::Template"; end

    def error_files
      files.select {|file| 
        file.error 
      }.sort_by{|file|
        begin
          if file.error && file.error.hammer_file != file 
            100
          else
            10
          end
        rescue
          1000
        end
      }
    end

    def html_files
      files.select {|file| (['.php', '.html'].include? File.extname(file.output_filename)) && !file.error && !file.include? }.compact
    end

    def html_includes
      files.select {|file| (['.php', '.html'].include? File.extname(file.output_filename)) && !file.error && file.include? }.compact
    end
    
    def compilation_files
      files.select {|file| 
        file.is_a_compiled_file # && file.source_files.collect(&:error) == [] 
        }.compact
    end
    
    def css_js_files
      files.select {|file| 
        ['.css', '.js'].include?(File.extname(file.output_filename)) && !file.is_a_compiled_file && !file.error
      }
    end
    
    def image_files
      files.select {|file| ['.png', '.gif', '.svg', '.jpg', '.gif'].include? File.extname(file.output_filename) }.compact
    end
    
    def other_files
      files - image_files - css_js_files - compilation_files - html_files - error_files - html_includes
    end
    
    def todo_files
      files.select {|file| 
        file.messages.length > 0
      }
    end
    
    def ignored_files
      @project.ignored_files rescue []
    end
  end
  
end
