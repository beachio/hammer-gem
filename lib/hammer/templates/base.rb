require 'erb'
require 'ostruct'

class ToErb < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end

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

  def to_s; raise "No such method"; end
end