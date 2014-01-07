require 'hammer/utils'
require 'hammer/error'

module Hammer
  class HammerFile

    attr_accessor :error_line, :error_message, :error_file, :error
    attr_accessor :path, :filename, :hammer_project, :output_filename, :output_path, 
                  :is_a_compiled_file, :compiled, :compiled_text, 
                  :from_cache

    def initialize options = {}
      # This is an initializer because I have this as a function.
      @filename = options.delete(:filename) if options[:filename]
      @path     = options.delete(:path) if options[:path]

      # self.raw_text = options.delete(:text) if options[:text]
    end

    def output_filename
      @output_filename ||= Hammer::Utils.output_filename_for(@filename)
    end

    # This attribute is lazy-loaded as some files don't need to be read.
    attr_writer :raw_text
    def raw_text
      if !@path && !@raw_text
        # raise "No path for this file!"
      else
        @raw_text ||= File.open(@path).read.to_s
      end
    end

    def path_to_file(filename)

      if filename.is_a? Hammer::HammerFile
        filename = filename.output_filename
      end

      other_path = Pathname.new(filename)
      this_path  = Pathname.new(File.dirname(self.filename))
      
      other_path.relative_path_from(this_path).to_s
    end

    def extension
      File.extname(@filename)[1..-1]
    end

  end
end