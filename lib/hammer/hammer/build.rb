require 'pathname'
require 'fileutils'
require 'shellwords'
require 'hammer/parser'
require 'hammer/templates/html'
require 'hammer/templates/commandline'

module Hammer

  class Build

    attr_accessor :error

    def initialize(options = {})
      @hammer_files = []
      @error = false

      @optimized        = options[:optimized] if options.keys.include? :optimized
      @input_directory  = Pathname.new(options.fetch(:input_directory)).cleanpath.to_s if options.include? :input_directory
      @output_directory = Pathname.new(options.fetch(:output_directory)).cleanpath.to_s if options.include? :output_directory
      @cache_directory  = Pathname.new(options.fetch(:cache_directory)).cleanpath.to_s if options.include? :cache_directory

      @results = EMPTY

      @output_directory ||= Dir.mktmpdir
      @cache_directory  ||= Dir.mktmpdir
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

    def ignore?(filename)
      return true if File.basename(filename).start_with? "_"
    end

    def filenames
      return @hammer_files if @hammer_files != []

      files = []
      file_paths.each do |file_path|
        # filename = file_path.to_s.gsub(@input_directory.to_s, "")
        # filename = filename[1..-1] if filename.start_with? "/"

        # unless ignore? file_path
          files << file_path
        # end
      end

      @hammer_files = files
    end

    def compile
      @results = {}

      filenames.each do |filename|
        path        = Pathname.new(filename).relative_path_from(Pathname.new(@input_directory)).to_s
        output_file = File.join(@output_directory, path)
        data        = {}

        # TODO: Caching

        Hammer::Parser.parse_file(@input_directory, path, @output_directory, @optimized) do |output, data|
          
          FileUtils.mkdir_p(File.dirname(output_file))
          File.open(output_file, 'w') do |f|
            f.write(output) if output
          end
          @results[path] = data

          @error = true if data[:error] 

          @results[path][:filename] = path
          @results[path][:output_filename] = path

          if path != Hammer::Parser.new.output_filename_for(path)
            @results[path][:output_filename] = Hammer::Parser.new.output_filename_for(path)
            FileUtils.move(output_file, File.join(@output_directory, Hammer::Parser.new.output_filename_for(path)))
          end
        end

      end

      return @results
    end

    def to_html
      compile() unless @results
      HTMLTemplate.new(@results).to_s
    end

    def wait(&complete)
      protect_against_zombies
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      compile(&complete)
    end
  end

  EMPTY = {}

end