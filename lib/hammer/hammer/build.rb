require 'pathname'
require 'fileutils'
require 'shellwords'
require 'hammer/parser'
require 'hammer/utils/ignore'
require 'hammer/cacher'

module Hammer

  class Build

    attr_accessor :error
    include Hammer::Ignore

    def initialize options = {}
      @results = {}
      @error = false

      @optimized        = options[:optimized] if options.keys.include? :optimized

      @input_directory  = clean_input(options.fetch(:input_directory))
      @output_directory = clean_input(options.fetch(:output_directory)) || Dir.mktmpdir
      @cache_directory  = clean_input(options.fetch(:cache_directory))  || Dir.mktmpdir

      @error = true if !File.exist? @input_directory

      Hammer::Parser.load_parsers_from_directory(@input_directory)
    end

    def compile
      @results = {}
      @cacher = Hammer::Cacher.new @input_directory, @cache_directory, @output_directory
      filenames.each do |filename|
        data = parse_file(filename)
        @results[data[:output_filename]] = data
        @error = true if data[:error]
      end
      @cacher.write_to_disk()

      added_files = @results.values.collect {|data| data[:added_files]}.flatten.compact
      added_files.each do |file|
        filename = file[:filenames].join(', ')
        @results[filename] = file
      end

      @ignored_files.each do |ignored_file|
        @results[ignored_file[:filename]] = ignored_file
      end

      return @results
    end

  private

    def clean_input input
      Pathname.new(input.to_s).cleanpath.to_s
    end

    def parse_file filename
      path = Pathname.new(filename).relative_path_from(Pathname.new(@input_directory)).to_s
      data = {:filename => path, :output_filename => path}

      # We don't want to parse includes!
      if File.basename(filename).start_with? "_"
        @cacher.cache(path, path, data)
        return data
      end

      # Now we'll need where this file is coming from, and where it's going to.
      output_path = Hammer::Parser.new.output_filename_for(path)
      input_file  = File.join(@input_directory, path)
      output_file = File.join(@output_directory, output_path)
      FileUtils.mkdir_p(File.dirname(output_file))

      data = {:filename => path, :output_filename => output_path}

      if @cacher.cached? path
        @cacher.copy_to output_path, @output_directory, path
        data.merge! @cacher.data[path]
        data[:from_cache] = true
      else
        Hammer::Parser.parse_file(@input_directory, path, @output_directory, @optimized) do |output, file_data|
          FileUtils.mkdir_p(File.dirname(output_file))
          File.open(output_file, 'w') { |f| f.write(output)} if output
          data.merge!(file_data) if data
          @cacher.cache(path, output_path, data)
        end
      end

      # Now touch the output file to the same time as the input file. Nice.
      FileUtils.touch(output_file, :mtime => File.mtime(input_file)) if File.exist? output_file
      return data
    end

    def filenames
      return [] unless @input_directory
      read_ignore_file(File.join(@input_directory, '.hammer-ignore'))
      @ignored_files = []
      Dir.glob(File.join(Shellwords.escape(@input_directory), "/**/*"), File::FNM_DOTMATCH).reject { |filename|
        path = filename.gsub(@input_directory+"/", "")
        if ignore?(path)
          if !File.directory?(filename) && !filename.start_with?(@output_directory)
            @ignored_files << {:filename => path, :output_filename => output_path = Hammer::Parser.new.output_filename_for(path), :ignored => true}
          end
          true
        end
      }
    end

  end
end