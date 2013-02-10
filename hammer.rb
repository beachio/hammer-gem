require "amp"

class Hammer
  
  def self.register_parser_for_extensions(parser_class, extensions)
    @@extensions_for ||= {}
    @@parsers_for ||= {}
    extensions.each do |extension|
      @@parsers_for[extension] ||= []
      @@parsers_for[extension] << parser_class
      @@extensions_for[parser_class] ||= []
      @@extensions_for[parser_class] << extension
    end
  end
  
  def self.register_parser_as_default_for_extensions(parser_class, extensions)
    @@default_parser_for ||= {}
    extensions.each do |extension|
      @@default_parser_for[extension] = parser_class
    end
  end

  def self.parser_for_extension(extension)
    @@default_parser_for[extension]
  end
  
  def self.parser_for_hammer_file(hammer_file)
    parser = @@default_parser_for[hammer_file.extension].new(hammer_file.hammer_project)
    parser.text = hammer_file.raw_text
    parser.hammer_file = hammer_file
    parser
  end

  def self.parsers_for_extension(extension)
    parsers = []
    new_extension = nil
    parser = Hammer.parser_for_extension(extension)
    parsers << parser
    
    while new_extension != parser.finished_extension
      new_extension = parser.finished_extension
      if new_extension != extension
        parser = Hammer.parser_for_extension(new_extension)
        parsers << parser
      end
    end
    
    parsers
  end
  
  def self.regex_for(filename, extension=nil)
    
    parsers = @@parsers_for[extension] || []
    
    # Cross-extensions. Means we can use any of these.
    extensions = []
    parsers.each do |parser|
      @@extensions_for[parser].each do |extension|
        extensions << extension
      end
    end
    
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

    def find_files_of_type(filename, extension)
      files ||= []
      regex = Hammer.regex_for(filename, extension)
      files = @hammer_files.select { |file| file.filename.match regex }
      return files
    end

    def find_files(filename, extension)
      self.find_files_of_type(filename, extension)
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
        parsers = Hammer.parsers_for_extension(hammer_file.extension)
        text = hammer_file.raw_text
        
        parsers.each do |parser|
          parser = parser.new
          parser.text = text
          text = parser.parse()
        end
        
        hammer_file.compiled_text = text
      end
      
      return @hammer_files
    end
    
  end

end