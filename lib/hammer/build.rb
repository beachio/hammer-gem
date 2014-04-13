require 'pathname'

module Hammer

  class Build
    def initialize(options = {})
      @hammer_files = []
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
      false
    end

    def filenames
      return @hammer_files if @hammer_files != []

      files = []
      file_paths.each do |file_path|
        filename = file_path.to_s.gsub(@input_directory.to_s, "")
        filename = filename[1..-1] if filename.start_with? "/"

        unless ignore? filename
          files << filename
        end
      end

      @hammer_files = files
    end

    def compile
      filenames.each do |filename|
        next if File.basename(filename).start_with? "_" # Skip include files!

        # TODO: Caching

        parsers = Hammer::Parser.for_filename(filename)
        return EMPTY if parsers.empty?

        last_parser = nil
        parsers.each do |parser_class|
          parser = parser_class.new
          if last_parser
            parser.from_json(last_parser.to_json)
          end
          parser.parse(filename)
          last_parser = parser
        end

        @results[filename] = last_parser.to_json
      end

      return @results
    end
  end

  EMPTY = {}

end