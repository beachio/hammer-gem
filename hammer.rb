require "amp"

class Hammer

  @@parsers = {}
  def self.register(parser_class, extension)
    @@parsers[extension] = parser_class
  end

  def self.parsers; @@parsers; end
  
  def self.parser_for(extension)
    @@parsers[extension]
  end
  
  def self.parser_for_hammer_file(hammer_file)
    parser = @@parsers[hammer_file.extension].new(hammer_file.hammer_project)
    parser.text = hammer_file.raw_text
    parser.hammer_file = hammer_file
    parser
  end
  
  def self.regex_for(filename, extensions=[])
    
    # /index.html becomes ^index.html  
    filename = filename.split("")[1..-1].join("") if filename.split("")[0] == "/"
    
    filename = Regexp.escape(filename).gsub('\*','.*?')
    if extensions != []
      /#{filename}\.(#{extensions.join("|")})/
    else
      /#{filename}/
    end
  end

  class Project

    def initialize()
      @hammer_files = [] 
    end

    def << (file)
      @hammer_files << file
    end

    def find_files_of_type(filename, final_extension)
      files ||= []
      
      # TODO: SCSS for CSS, etc
      extensions = [final_extension]
      
      regex = Hammer.regex_for(filename, extensions)
      files = @hammer_files.select { |file| file.filename.match regex }
      return files
    end

    def find_files(filename, parser)
      extensions = [Hammer.parsers.invert[parser.class]]
      files = self.find_files_of_type(filename, extensions)
      return files
    end
    
    # TODO: Create root_directory, output_directory and temporary_directory
    # could be while creating
    def root_directory
      nil
    end

    def find_file(filename, parser_class)
      find_files(filename, parser_class)[0]
    end
    
    def compile()
      @compiled_hammer_files = []
      
      @hammer_files.each do |hammer_file|
        parser = hammer_file.parser.new
        parser.text = hammer_file.text
        hammer_file.text = parser.parse()
      end
      
      return @hammer_files
    end
    
  end

end