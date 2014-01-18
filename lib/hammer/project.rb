require 'hammer/file'
require 'hammer/file_compiler'
require 'hammer/cacher'

module Hammer
  class Project

    attr_accessor :hammer_files, :production, :cache_directory, :input_directory, :output_directory

    def initialize(options = {})
      @hammer_files = []
      @production       = options.keys.include? :optimized
      @input_directory  = options.fetch(:input_directory) if options.include? :input_directory
      @output_directory = options.fetch(:output_directory) if options.include? :output_directory
      @cache_directory  = options.fetch(:cache_directory) if options.include? :cache_directory

      @output_directory ||= Dir.mktmpdir
      @cache_directory ||= Dir.mktmpdir
    end

    def error
      @hammer_files.each do |file|
        return true if file.error
      end
      false
    end

    def << (file)
      @hammer_files << file
    end

    def read

      return @hammer_files if @hammer_files != []

      files = []
      file_paths.each do |file_path|
        filename = file_path.to_s.gsub(@input_directory.to_s, "")
        filename = filename[1..-1] if filename.start_with? "/"

        hammer_file = Hammer::HammerFile.new 
        hammer_file.path = file_path
        hammer_file.filename = filename
        hammer_file.hammer_project = self

        if ignore_file? hammer_file
          hammer_file.ignored = true
          @ignored_files << hammer_file
        else
          files << hammer_file
        end
        
      end
      
      @hammer_files = files
    end

    def compile

      read()

      # Initialize the cacher up here
      cacher

      # We're returning an array of compiled hammerfiles.
      compiled_hammer_files = []

      hammer_files.each do |hammer_file|
        # Skip include files!
        next if File.basename(hammer_file.filename).start_with? "_"

        # Check whether we've got a cached file for this
        if cached? hammer_file
          hammer_file.from_cache = true
          hammer_file.messages = cacher.messages_for(hammer_file.filename)
        else
          compile_file(hammer_file)
        end

        compiled_hammer_files.push hammer_file
        cache_hammer_file(hammer_file)
      end

      # We're done here. Write out the cacher's new caching config stuff.
      cacher.write_to_disk

      return compiled_hammer_files
    end

    def ignore?(hammer_file)
      true
    end

    # Check a hammer_file for whether we should ignore it.
    def ignore_file?(hammer_file)
      ignored_paths.include? hammer_file.path
    end
    
    # Parse our HAMMER_IGNORE_FILENAME file, register it against our input_directory.
    def ignored_paths
      return [] unless input_directory
      return @ignored_paths if @ignored_paths
      
      ignore_file = File.join(input_directory, HAMMER_IGNORE_FILENAME)
      
      @ignored_paths = [ignore_file]
      if File.exists?(ignore_file)
        lines = File.open(ignore_file).read.split("\n")
        lines.each do |line|
          line = line.strip
          @ignored_paths << Dir.glob(File.join(input_directory, "#{line}/**/*"))
          @ignored_paths << Dir.glob(File.join(input_directory, "#{line.gsub("*", "**/*")}"))
        end
      end
      @ignored_paths.flatten!.uniq!
      return @ignored_paths || []
    rescue
      # TODO: Find out whether we actually use this rescue block.
      # It would be good to be able to output debug information into a console somewhere.
      []
    end

    def cache_hammer_file(hammer_file)
      if hammer_file.error
        cacher.clear_cached_contents_for(hammer_file.filename)
      elsif hammer_file.compiled_text
        cacher.set_cached_contents_for(hammer_file.filename, hammer_file.compiled_text)
      else
        cacher.cache(hammer_file.path, hammer_file.filename)
      end
    end

    def cacher
      @cacher ||= ProjectCacher.new :hammer_project => self, :directory => @cache_directory, :input_directory => @input_directory
    end

    # Check whether a hammer_file is cached. Uses the @cacher object.
    def cached? hammer_file
      cacher.valid_cache_for(hammer_file.filename)
    end

    def cache(hammer_file)
      return unless @cacher
      if hammer_file.error
        @cacher.clear_cached_contents_for(hammer_file.filename)
      elsif hammer_file.compiled_text
        @cacher.set_cached_contents_for(hammer_file.filename, hammer_file.compiled_text)
      else
        @cacher.cache(hammer_file.path, hammer_file.filename)
      end
    end

    def compile_file(hammer_file)
      # TODO: Compiler.compile() should probably return a new hammer file rather than mutating the hammer_file object!
      compiler = Hammer::FileCompiler.new(:hammer_file => hammer_file, :hammer_project => self)
      compiler.compile()
      cache(hammer_file)
    end

    # Writes out to the project.
    def write
      @errors = 0
      output_directory = @output_directory
      hammer_files.each do |hammer_file|
        if !File.basename(hammer_file.filename).start_with?("_")
          
          sub_directory   = File.dirname(hammer_file.output_filename)
          final_location  = File.join output_directory, sub_directory
          
          FileUtils.mkdir_p(final_location)
          
          output_path = File.join(output_directory, hammer_file.output_filename)
          output_path = Pathname.new(output_path).cleanpath
          hammer_file.output_path = output_path
          
          @errors += 1 if hammer_file.error

          if @cacher && hammer_file.from_cache
            cache_path = @cacher.cached_path_for(hammer_file.filename)
            
            if !File.exists? hammer_file.output_path
              FileUtils.cp(cache_path, hammer_file.output_path)
            end
            
          elsif hammer_file.compiled_text
            f = File.new(output_path, "w")
            f.write(hammer_file.compiled_text)
            f.close
          else
            FileUtils.cp(hammer_file.path, hammer_file.output_path)
          end
        end
      end
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

    # Project-wide file finding.
    # TODO: We might want to put this inside a helper object?
    def find_files(filename, extension=nil)
      @cached_files ||= {}
      if @cached_files["#{filename}:#{extension}"]
        return @cached_files["#{filename}:#{extension}"]
      end
      
      filename = filename[1..-1] if filename.start_with? "/"
      regex = Hammer::Utils.regex_for(filename, extension)

      hammer_files()

      files = @hammer_files.select { |file|
        
        match = file.filename =~ regex
        straight_basename = false  # File.basename(file.filename) == filename
        
        no_extension_required = extension.nil?
        has_extension = File.extname(file.filename) != ""
        
        (has_extension || no_extension_required) && (match)
      }.sort_by {|file| 
        file.filename.to_s
      }.sort_by { |file|
      
        basename = File.basename(file.filename)
        match         = basename == [filename, extension].compact.join(".")
        partial_match = basename == ["_"+filename, extension].compact.join(".")
        
        if match
          file.filename.split(filename).join.length
        elsif partial_match
          file.filename.split(filename).join.length + 10
        else
          file.filename.split(filename).join.length + 100
        end
        
      }
      
      if files && files.length > 0 && !filename.include?('*')
        files = [files[0]]
      end
      @cached_files["#{filename}:#{extension}"] = files
      return files
    end
    
    def find_file(filename, extension=nil)
      find_files(filename, extension)[0]
    end

  end
end
