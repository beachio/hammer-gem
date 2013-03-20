HAMMER_IGNORE_FILENAME = "ignore.txt"

class Hammer
  class Project

    def initialize(production=false)
      @production = production
      @ignored_files = []
      @hammer_files = [] 
    end
    
    attr_reader :production
    
    attr_accessor :hammer_files, :ignored_files, :input_directory
    
    def create_hammer_files_from_directory(input_directory, output_directory)

      files = Dir.glob(File.join(Shellwords.escape(input_directory), "/**/*"))
      
      escaped_input_directory  = input_directory.gsub(/([\[\]\{\}\*\?\\])/, '\\\\\1')
      escaped_output_directory = output_directory.gsub(/([\[\]\{\}\*\?\\])/, '\\\\\1')

      input_directory          = Pathname.new(input_directory).cleanpath.expand_path.to_s
      @input_directory = input_directory
      output_directory         = Pathname.new(output_directory).cleanpath.expand_path.to_s
      
      # files = Dir.glob(File.join(input_directory, "**/*"))
      files.reject! {|file| file.match(output_directory)}
      
      ignore_file = File.join(input_directory, HAMMER_IGNORE_FILENAME)
      
      @ignored_paths = []
      if File.exists?(ignore_file)
        lines = File.open(ignore_file).read.split("\n")
        lines.each do |line|
          @ignored_paths << Dir.glob(File.join(input_directory, "**/#{line}"))
        end
      end
      
      @ignored_paths.flatten!
      @ignored_paths.uniq!
      
      files.each do |filename|
        
        next if File.directory?(filename)
        
        hammer_file = Hammer::HammerFile.new
        hammer_file.full_path = filename
        hammer_file.raw_text = File.read(filename)
        hammer_file.filename = filename.to_s.gsub(input_directory.to_s, "")
        hammer_file.filename = hammer_file.filename[1..-1] if hammer_file.filename.start_with? "/"
        hammer_file.hammer_project = self
        
        if @ignored_paths.include? hammer_file.full_path
          @ignored_files << hammer_file
        else
          @hammer_files << hammer_file
        end
      end
      
      return @hammer_files
    end
    
    def << (file)
      @hammer_files << file
    end

    def find_files(filename, extension=nil)
      
      @cached_files ||= {}
      if @cached_files["#{filename}:#{extension}"]
        return @cached_files["#{filename}:#{extension}"]
      end
      
      filename = filename[1..-1] if filename.start_with? "/"
      regex = Hammer.regex_for(filename, extension)

      files = @hammer_files.select { |file|
        file.filename =~ regex || File.basename(file.filename) == filename
      }.sort_by {|file| 
        file.filename.to_s
      }.sort_by { |file|
        file.filename.split(filename).join().length
      }
      
      @cached_files["#{filename}:#{extension}"] = files
      return files
    end
    
    def find_file(filename, extension=nil)
      find_files(filename, extension)[0]
    end
    
    def parser_for_hammer_file(hammer_file)
      parser = Hammer.parser_for_extension(hammer_file.extension).new(hammer_file.hammer_project)
      parser.hammer_project = self
      parser.text = hammer_file.raw_text
      parser.hammer_file = hammer_file
      parser
    end
    
    ## The compile method. This does all the files.
    
    def compile()
      @compiled_hammer_files = []
      @hammer_files.each do |hammer_file|
        
        @compiled_hammer_files << hammer_file
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
          hammer_file.error = Hammer::Error.new(error.to_s, nil)
        end
      end
      
      return @hammer_files
    end
    
  private
  
    ## Compilation stages: Before, during and after.
    def pre_compile(hammer_file)
      todos = TodoParser.new(self, hammer_file).parse()
      todos.each do |line_number, message|
        hammer_file.messages.push({:line => line_number, :message => message, :html_class => 'todo'})
      end
    end
    
    def compile_hammer_file(hammer_file)
      text = hammer_file.raw_text
      Hammer.parsers_for_extension(hammer_file.extension).each do |parser|
        parser = parser.new(self)
        parser.hammer_file = hammer_file
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