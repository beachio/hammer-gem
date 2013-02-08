class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end


$FILE_PATH = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(File.dirname(File.expand_path(__FILE__)), "lib")

## Let's start by $LOAD_PATHing all the directories inside vendor/gems/*/lib
["vendor/gems/*"].each do |directory|
  Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), directory)).each do |dir|
    d = File.directory?(lib = "#{dir}/lib") ? lib : dir
    $LOAD_PATH << d
  end
end

## Now require all the gems we need
require 'json'
require 'fileutils'
require 'sass'
require 'plist'
require 'execjs'
require 'coffee-script'
require 'cgi'
require 'bourbon'
require 'kramdown'
require 'shellwords'
require 'haml'
require 'timeout'
require 'amp'
require 'uglifier'

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
    parser
  end

  class Project

    def initialize()
      @hammer_files = [] 
    end

    def << (file)
      @hammer_files << file
    end

    def find_files(filename, parser)
      
      # warn "find_files is still unclever and needs sorting and caching"
      
      files ||= []
      extensions = Hammer.parsers.invert[parser.class]
      
      extensions.each do |extension|
        @hammer_files.each do |hammer_file|
          if hammer_file.filename == [filename, extension].join('.')
            files << hammer_file
          end
        end
      end
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