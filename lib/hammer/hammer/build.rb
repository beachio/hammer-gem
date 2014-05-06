require 'pathname'
require 'fileutils'
require 'shellwords'
require 'hammer/parser'
require 'hammer/cacher'

module Hammer

  EMPTY = {}

  class Build

    attr_accessor :error, :cacher

    def clean_input(input)
      Pathname.new(input.to_s).cleanpath.to_s
    end

    def initialize(options = {})
      @hammer_files = []
      @error        = false

      @optimized        = options[:optimized] if options.keys.include? :optimized

      @input_directory  = clean_input(options.fetch(:input_directory))
      @output_directory = clean_input(options.fetch(:output_directory)) || Dir.mktmpdir
      @cache_directory  = clean_input(options.fetch(:cache_directory))  || Dir.mktmpdir

      Hammer::Parser.load_parsers_from_directory(@input_directory)
      @results = EMPTY
    end

    # Let's create a list of filenames in the Hammer project.
    # We ignore anything with .git, .svn and .DS_Store.
    # This keeps our set of hammer files nice and sane.
    def file_paths
      paths = []
      if @input_directory

        paths = Dir.glob(File.join(Shellwords.escape(@input_directory), "/**/*"), File::FNM_DOTMATCH)

        paths.reject! { |a| a =~ /\/\.git\// }
        paths.reject! { |a| a =~ /\/\.svn\// }
        paths.reject! { |a| a =~ /\.DS_Store/ }
        paths.reject! {|file| file.include?(@output_directory)}
        paths.reject! {|file| File.directory?(file)}

        # .ht files are Apache!
        paths.reject! {|file| File.basename(file).start_with?('.') && !File.basename(file).start_with?('.ht')}

        # This is where I tried to ignore directories which start with a .
        # TODO: ignore directories which start with a .
        # files.reject! {|file| file.split("/")[0..-2].select { |directory| directory.start_with? "."}.length > 0}
        # files.reject! { |a| a =~ /\.{1,2}$/ }
      end

      paths
    end

    # def ignore?(filename)
    #   return true if File.basename(filename).start_with? "_"
    # end

    def filenames
      return @hammer_files if @hammer_files != []

      files = []
      file_paths.each do |file_path|
        filename = file_path.to_s.gsub(@input_directory.to_s, "")
        # filename = filename[1..-1] if filename.start_with? "/"

        # Filename with no extension
        next if file_path.include?(@output_directory)
        next unless File.basename(file_path).include? "."
        next if file_path.include? ".sass-cache"

        # unless ignore? file_path
          files << file_path
        # end
      end

      @hammer_files = files
    end

    def compile
      @results = {}

      # TODO: Read
      @cacher = Hammer::Cacher.new @input_directory, @cache_directory, @output_directory

      added_files = []

      filenames.each do |filename|
        path        = Pathname.new(filename).relative_path_from(Pathname.new(@input_directory)).to_s
        output_file = File.join(@output_directory, path)
        data        = {}

        FileUtils.mkdir_p(File.dirname(output_file))

        # next if File.basename(filename).start_with? "_"

        output_path = Hammer::Parser.new.output_filename_for(path)
        input_file = File.join(@input_directory, path)
        output_file = File.join(@output_directory, output_path)

        # TODO: Caching
        file_data = {:filename => path, :output_filename => output_path}

        if @cacher.cached? path
          @cacher.copy_to(output_path, @output_directory, path)
          if @cacher.data[path]
            @results[path] = @cacher.data[path]
          else
            @results[path] = file_data
          end
          @results[path][:from_cache] = true
          data = @cacher.data[path]

        else
          Hammer::Parser.parse_file(@input_directory, path, @output_directory, @optimized) do |output, data|

            if !File.basename(path).start_with?("_") && !path.end_with?(".rb")
              File.open(output_file, 'w') { |f| f.write(output) if output }
            end

            @results[path] = data
            @error = true if data[:error]
            @results[path][:filename] = path
            @results[path][:output_filename] = output_path

            added_files += data[:added_files] if data[:added_files]

            file_data = file_data.merge(data)
          end

          @cacher.cache(path, output_path, file_data)
        end

        FileUtils.touch output_file, :mtime => File.mtime(input_file)
      end

      @cacher.write_to_disk()

      added_files.each do |file|
        filename = file[:filenames].join(', ')
        @results[filename] = file
      end
      return @results
    end
  end
end