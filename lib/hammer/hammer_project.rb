# TODO: Rename me
HAMMER_IGNORE_FILENAME = ".hammer-ignore"

class Hammer
  class Project

    attr_reader :production, :errors
    attr_accessor :hammer_files, :ignored_files, :input_directory, :cache_directory, :output_directory, :error

    # TODO: Replace all initializations with the hash-based method.

    def initialize(production_or_options=false)
      if production_or_options.is_a? Hash
        setup(production_or_options)
      else
        @error = nil
        @production = production
        @ignored_files = []
        @hammer_files = []
      end
    end
    
    def setup(options)
      @production       = options[:production] == true # this parameter is optional
      
      @input_directory  = options.fetch(:input_directory)
      @output_directory = options.fetch(:output_directory)
      @cache_directory  = options.fetch(:cache_directory)
      
      # TODO: turn these into private methods as we don't need accessors.
      @file_paths       = file_paths()
      @ignored_paths    = ignored_paths()
      @hammer_files     = hammer_files()
      
      @cacher = Hammer::Cacher.new(self, @cache_directory)
    end






    
    
    # Hammer cacher object.
    # We use this to check staleness of files and retrieve their cached contents.
    
    def cacher
      @cacher ||= Hammer::Cacher.new(self, @cache_directory)
    end
    





    ## Sanitized setters
    # We need to ensure that input_directory and output_directory are clean and expanded.
    
    def input_directory=(new_input_directory)
      @input_directory = Pathname.new(new_input_directory.to_s).cleanpath.expand_path.to_s
    end
    
    def output_directory=(new_output_directory)
      @output_directory = Pathname.new(new_output_directory.to_s).cleanpath.expand_path.to_s
    end





    
    # Let's create a list of filenames in the Hammer project.
    # We ignore anything with .git, .svn and .DS_Store.
    # This keeps our set of hammer files nice and sane.
    def file_paths
      files = []
      if input_directory
        files = Dir.glob(File.join(Shellwords.escape(input_directory), "/**/*"), File::FNM_DOTMATCH)
        
        files.reject! { |a| a =~ /\/\.git\// }
        files.reject! { |a| a =~ /\/\.svn\// }
        files.reject! { |a| a =~ /\.DS_Store/ }
        files.reject! {|file| file.include?(output_directory)}
        files.reject! {|file| File.directory?(file)}
        
        # .ht files are Apache!
        files.reject! {|file| File.basename(file).start_with?('.') && !File.basename(file).start_with?('.ht')}
        
        # This is where I tried to ignore directories which start with a .
        # TODO: ignore directories which start with a .
        # files.reject! {|file| file.split("/")[0..-2].select { |directory| directory.start_with? "."}.length > 0}
        # files.reject! { |a| a =~ /\.{1,2}$/ }
      end
      
      files
    end
    
    # Check a hammer_file for whether we should ignore it.
    def ignore_file?(hammer_file)
      ignored_paths.include? hammer_file.full_path
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
    
    
    
    # This creates an array of @hammer_files and an array of @ignored_files.
    
    def hammer_files
      return @hammer_files if @has_created_hammer_files
      
      @hammer_files = []
      @ignored_files = []
      
      file_paths.each do |file_path|
        
        filename = file_path.to_s.gsub(@input_directory.to_s, "")
        filename = filename[1..-1] if filename.start_with? "/"
        
        hammer_file = Hammer::HammerFile.new :filename => filename, 
                                             :full_path => file_path, 
                                             :hammer_project => self
        
        if ignore_file? hammer_file
          @ignored_files << hammer_file
        else
          @hammer_files << hammer_file
        end
      end
      
      @has_created_hammer_files = true
      return @hammer_files
    end
    
    # Shorthand for "add a hammer file to this project."
    def << (file)
      @hammer_files << file
    end


    # Project-wide file finding.
    # TODO: We might want to put this inside a helper object?
    def find_files(filename, extension=nil)
      
      @cached_files ||= {}
      if @cached_files["#{filename}:#{extension}"]
        return @cached_files["#{filename}:#{extension}"]
      end
      
      filename = filename[1..-1] if filename.start_with? "/"
      regex = Hammer.regex_for(filename, extension)

      files = hammer_files.select { |file|
        
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
    
    
    # Parser chain management.
    def parser_for_hammer_file(hammer_file)
      parser_type = Hammer.parser_for_extension(hammer_file.extension)
      if parser_type
        parser = parser_type.new(hammer_file.hammer_project)
        parser.hammer_project = self
        parser.text = hammer_file.raw_text
        parser.hammer_file = hammer_file
        parser
      else
        # raise "No parser found for #{hammer_file.filename}"
        nil
      end
    end
    
    ## The compile method. This does all the files.
    def compile()
      @compiled_hammer_files = []
      
      # Ensure cacher has been created.
      cacher() unless @cacher
      
      hammer_files.each do |hammer_file|
        
        @compiled_hammer_files << hammer_file
        
        cached = @cacher.valid_cache_for(hammer_file.filename)
        if cached
          hammer_file.from_cache = true
          hammer_file.messages = @cacher.messages_for(hammer_file.filename)
        else
          begin
            hammer_file.hammer_project ||= self
            pre_compile(hammer_file)
            next if File.basename(hammer_file.filename).start_with? "_"
            compile_hammer_file(hammer_file)
            after_compile(hammer_file)
          rescue Hammer::Error => error
            hammer_file.error = error
          rescue => error
            # In case there's another error!
            hammer_file.error = Hammer::Error.from_error(error, hammer_file)
          end
          
          
          if hammer_file.error
            @cacher.clear_cached_contents_for(hammer_file.filename)
          elsif hammer_file.compiled_text
            @cacher.set_cached_contents_for(hammer_file.filename, hammer_file.compiled_text)
          else
            @cacher.cache(hammer_file.full_path, hammer_file.filename)
          end
        end
      end
      
      @cacher.write_to_disk
      
      return !errors.any?
    end
    
    def errors
      hammer_files.collect(&:error).compact
    end
    
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

          if hammer_file.from_cache
            cache_path = @cacher.cached_path_for(hammer_file.filename)
            
            if !File.exists? hammer_file.output_path
              FileUtils.cp(cache_path, hammer_file.output_path)
            end
            
          elsif hammer_file.compiled_text
            f = File.new(output_path, "w")
            f.write(hammer_file.compiled_text)
            f.close
          else
            FileUtils.cp(hammer_file.full_path, hammer_file.output_path)
          end
        end
      end
    end
    
    def reset
      @cacher.clear()
      hammer_files()
    end
    
  private
  
    ## Compilation stages: Before, during and after.
    def pre_compile(hammer_file)
      todos = TodoParser.new(self, hammer_file).parse()
      todos.each do |line_number, messages|
        messages.each do |message|
          hammer_file.messages.push({:line => line_number, :message => message, :html_class => 'todo'})
        end
      end
    end
    
    def compile_hammer_file(hammer_file)
      # text = hammer_file.raw_text
      text = nil
      Hammer.parsers_for_extension(hammer_file.extension).each do |parser|
        parser = parser.new(self)
        parser.hammer_file = hammer_file
        text ||= hammer_file.raw_text
        parser.text = text
        text = parser.parse()
        hammer_file.compiled = true
      end
      hammer_file.output_filename = Hammer.output_filename_for(hammer_file)
      hammer_file.compiled_text = text
    end
    
    def after_compile(hammer_file)
      
      return unless @production
      return unless hammer_file.is_a_compiled_file
      
      filename = hammer_file.output_filename
      extension = File.extname(filename)[1..-1]
      compilers = Hammer.after_compilers[extension] || []
      
      compilers.each do |precompiler|
        hammer_file.compiled_text = precompiler.new(hammer_file.compiled_text).parse()
      end
    end
    
  end
end