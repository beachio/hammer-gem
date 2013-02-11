class Hammer
  class Project

    def initialize()
      @hammer_files = [] 
    end
    
    def create_hammer_files_from_directory(input_directory)
      Dir.glob(File.join(input_directory, "**/*")).each do |filename|
        
        next if File.directory?(filename)
        
        hammer_file = Hammer::HammerFile.new
        hammer_file.full_path = filename
        hammer_file.raw_text = File.read(filename)
        hammer_file.filename = filename.gsub(input_directory, "")
        
        @hammer_files << hammer_file
      end
      
      return @hammer_files
    end
    
    def << (file)
      @hammer_files << file
    end

    def find_files(filename, extension=nil)
      
      # If they're finding (index.html, html) we need to remove the .html from the tag.
      if extension && filename[-extension.length-1..-1] == ".#{extension}" 
        filename = filename[0..-extension.length-2]
      end
      
      regex = Hammer.regex_for(filename, extension)
      files = @hammer_files.select { |file|
        file.filename.to_s.match regex
      }.sort_by { |file|
        file.filename.split(filename).join().length
      }
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
    
    def compile()
      @compiled_hammer_files = []
      
      @hammer_files.each do |hammer_file|
        
        next if File.basename(hammer_file.filename).split("")[0] == "_"
        
        text = hammer_file.raw_text
        extension = ""
        
        Hammer.parsers_for_extension(hammer_file.extension).each do |parser|
          parser = parser.new
          parser.hammer_project = self
          parser.hammer_file = hammer_file
          parser.text = text
          text = parser.parse()
          
          hammer_file.output_filename = "#{File.dirname(hammer_file.filename)}/#{File.basename(hammer_file.filename, ".*")}.#{parser.class.finished_extension}"
        end
        
        hammer_file.output_filename ||= hammer_file.filename
        
        hammer_file.compiled_text = text
      end
      
      return @hammer_files
    end
  end
end