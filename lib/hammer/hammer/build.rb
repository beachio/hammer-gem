require 'pathname'
require 'fileutils'
require 'shellwords'
require 'hammer/parser'
require 'hammer/utils/ignore'
require 'hammer/cacher'
require 'parallel'

module Hammer
  class Build
    attr_accessor :error
    include Hammer::Ignore
    include Parallel::ProcessorCount

    def initialize options = {}
      @results = {}
      @error = false

      @optimized        = options[:optimized] if options[:optimized]

      @input_directory  = clean_input(options.fetch(:input_directory))
      Settings.input_directory = @input_directory
      @output_directory = clean_input(options.fetch(:output_directory)) || Dir.mktmpdir
      @cache_directory  = clean_input(options.fetch(:cache_directory))  || Dir.mktmpdir

      @error = true if !File.exist? @input_directory

      # Load in any *_parser.rb files in the directory.
      Hammer::Parser.load_parsers_from_directory(@input_directory, "*_parser.rb")
    end

    def compile
      @results = {}
      @cacher = Hammer::Cacher.new @input_directory, @cache_directory, @output_directory

      ignore_file   = File.join(@input_directory, '.hammer-ignore')
      filenames    = files_from_directory(@input_directory, ignore_file)
      ignored_files = ignored_files_from_directory(@input_directory, ignore_file)

      # first we parse assets, because we need assets to be done when we parse pages
      # allowed pages formats are %{html htm md slim haml}
      # then we generate content pages (it will also register file paths)
      # finally we parse existing pages
      pages_filenames, assets_filenames = filenames.partition do |f|
        %w{.html .htm .md .slim .haml}.include?(File.extname(f).downcase)
      end

      Parallel.map(assets_filenames, in_threads: processor_count) do |filename|
        parse_file(filename)
      end.each do |data|
        @results[data[:output_filename]] = data
        @error = true if data[:error]
      end

      generated_results = ContentGenerator.new(
        @input_directory,
        @output_directory
      ).process

      Parallel.map(pages_filenames, in_threads: processor_count) do |filename|
        parse_file(filename)
      end.each do |data|
        @results[data[:output_filename]] = data
        @error = true if data[:error]
      end

      @cacher.write_to_disk()

      added_files = @results.values.collect {|data| data[:added_files]}.flatten.compact
      added_files.each do |file|
        filename = file[:filenames].join(', ')
        @results[filename] = file
      end

      ignored_files.each do |ignored_file|
        path = ignored_file.gsub(@input_directory+"/", "")
        ignored_file = {:filename => path, :output_filename => Hammer::Parser.new.output_filename_for(path), :ignored => true}
        @results[ignored_file[:filename]] = ignored_file
      end

      @results[:generated] = generated_results

      if @optimized
        # remove empty directories
        # since we joined css and js into single files and moved them to assets
        # directory, some directories may be empty
        Dir[@output_directory + '/**/'].reverse_each do |d|
          Dir.rmdir d if Dir.entries(d).size == 2
        end
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

      if @cacher.cached?(path) && @cacher.data[path]
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
  end
end