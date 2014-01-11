require 'templatey/templatey'
require 'forwardable'

module Hammer
  class Parser

    include Templatey

    attr_accessor :hammer_project, :hammer_file, :variables, :text, :production, :input_directory, :output_directory, :cache_directory

    extend Forwardable
    def_delegators :@hammer_file, :filename

    def initialize(options={})
      @hammer_project = options.fetch(:hammer_project) if options.include? :hammer_project
      @hammer_file = options.fetch(:hammer_file) if options.include? :hammer_file
      @text = ""
      @text = options.fetch(:text) if options.include? :text
    end

    # def text
      # (@text ||= @hammer_file.raw_text.to_s).to_s
    # end

    def hammer_project=(hammer_project)
      @production = hammer_project.production
      @input_directory = hammer_project.input_directory
      @output_directory = hammer_project.output_directory
      @cache_directory = hammer_project.cache_directory
      @text = @hammer_file.raw_text.to_s
    end

    ## Dependencies
    # This adds a wildcard dependency to the file.
    def add_wildcard_dependency(filename, extension=nil)
      # @hammer_project.cacher.add_wildcard_dependency(@hammer_file.filename, filename, extension)
    end

    def add_file_dependency(file)
      # @hammer_project.cacher.add_file_dependency(@filename, file.filename)
    end


    # Find matching files in the current project.
    # Adds a wildcard dependency for this filename and extension for caching purposes.
    def find_files(filename, extension=nil)
      add_wildcard_dependency(filename, extension)
      find_files_without_adding_dependency(filename, extension)
    end
    # The same as find_files, without creating the dependency.
    def find_files_without_adding_dependency(filename, extension=nil)
      @hammer_project.find_files(filename, extension)
    end


    # Find a single file in the project.
    # Also, add a filename dependency to the file.
    def find_file(filename, extension=nil)
      file = find_file_without_adding_dependency(filename, extension)
      add_file_dependency(file)
      return file
    end
    # Find a single file without adding a filename dependency.
    def find_file_without_adding_dependency(filename, extension=nil)
      find_files_without_adding_dependency(filename, extension)[0]
    end


    ## Actual parser stuff
    # Replace strings in a file. Calls a block on the line.
    def replace(regex, &block)
      lines = []
      if @text.to_s.scan(regex).length > 0
        line_number = 0
        @text = @text.to_s.split("\n").map { |line| 
          line_number += 1
          line.gsub(regex) { |match|
            begin 
              block.call(match, line_number) 
            rescue => error_message
              error(error_message, line_number)
            end
          }
        }.join("\n")
      end
      return
    end

    ## TODO: Add error messages to hammer file compiling.
    ## Called from replace whenever an error is created.
    def error(text, line_number, alternate_hammer_file = nil, error=nil)
      subject = alternate_hammer_file
      subject ||= @hammer_file

      error = Hammer::Error.new(text, line_number)
      error.hammer_file = subject
      error.original_error = error
      subject.error = error

      raise subject.error
    end

    ### Class methods

    ## Parser finders

    # Parser chain: fetches the next parser class that can handle this extension.

    class << self
      def parsers_for_array
        @@parsers_for
      end

      def next_parser
        if respond_to? :finished_extension
          parsers = @@parsers_for[self.finished_extension]
          index = parsers.index(self)
          return unless index
          return parsers[index+1]
        end
      end

      # Returns an array of parsers that can compile a given extension.
      def for_extension(extension)
        
        parser = @@default_parser_for[extension]
        if @@parsers_for && @@parsers_for[extension] && !parser
          parser = @@parsers_for[extension][0]
        end
        
        return [] unless parser
        
        parsers = [parser]
        if @@parsers_for[extension]
          parsers += @@parsers_for[extension]
          parser = parsers.last
        end
        
        new_extension = nil
        
        while new_extension != parser.finished_extension
          new_extension = parser.finished_extension
          if new_extension != extension
            parsers << @@parsers_for[extension] # Hammer::Parser.for_extension(new_extension)
          end
        end
        
        return parsers.uniq.flatten
      end
      
      # Returns a parser object for a Hammer file object
      def for_hammer_file(hammer_file)
        parser_class = @@default_parser_for[hammer_file.extension]

        raise "Unrecognised format: #{hammer_file.extension}" unless parser_class

        parser = parser_class.new({
          :hammer_file => hammer_file, 
          :hammer_project => hammer_file.hammer_project
         })
        parser.text = hammer_file.raw_text
        parser
      end

      # Find all parsers that have been registered
      def parsers_for
        @@parsers_for
      end
      def all
        @@parsers
      end

      # Load and require all Hammer parsers.
      def require_all
        # Include all the parsers from the parsers directory
        parsers_path = File.join(File.dirname(__FILE__), 'parsers', '*')
        parsers      = Pathname.glob(parsers_path)
        parsers.each { |file| require "hammer/parsers/#{file.basename(file.extname)}" }
      end

      ## Finding parsers

      # Fetch all extensions for a type of parser
      def extensions_for(parser_class)
        @@extensions_for[parser_class]
      end

      ## Parser registrations

      # Register as being the first parser that can handle an extension.
      def register_as_default_for_extensions(klass, extensions)
        @@default_parser_for ||= {}
        extensions.each do |extension|
          @@default_parser_for[extension] = klass
        end
      end

      # Add a parser to the series of parsers that can handle an extension.
      def register_for_extensions(klass, extensions)
        extensions = [*extensions]
        @@parsers ||= []
        @@parsers << klass
        @@extensions_for ||= {}
        @@parsers_for ||= {}
        extensions.each do |extension|
          @@parsers_for[extension] ||= []
          @@parsers_for[extension] << klass
          @@extensions_for[klass] ||= []
          @@extensions_for[klass] << extension
        end
      end
    end

  end
end

Hammer::Parser.require_all()