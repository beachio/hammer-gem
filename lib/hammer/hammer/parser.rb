require 'parsers/modules/extensions'
require 'parsers/modules/variables'
require 'parsers/modules/optimizer'
require 'parsers/modules/adding_files'
require 'parsers/modules/finding_files'
require 'parsers/modules/dependencies'
require 'parsers/modules/replacement'
require 'parsers/modules/paths'

module Hammer
  class Parser

    #TODO: Do we move dependencies into a module?
    attr_accessor :text
    attr_accessor :dependencies, :wildcard_dependencies
    attr_accessor :path, :directory, :variables, :messages, :todos
    attr_accessor :added_files
    include Replacement
    include Extensions
    include Variables
    include AddingFiles
    include FindingFiles
    include Dependency
    include Paths

    def initialize(options={})
      @path ||= options[:path]
      @wildcard_dependencies = {}
      @filenames = []
      @directory = Dir.mktmpdir
    end

    def h(text)
      text # TODO: HTMLify
    end

    def filename
      path
    end

    def path=(new_path)
      raise "New path was a Pathname" if new_path.is_a? Pathname
      @path = new_path
      @filenames = Dir.glob(File.join(@path, "**/*"))
    end
    
    def parse(text="")
      return text
    end

    # Used when creating a parser, to initialize variables from the last parser.
    def from_hash(hash)
      self.variables = hash[:variables]
      self.messages = hash[:messages]
      self.wildcard_dependencies = hash[:wildcard_dependencies]
      self.dependencies = hash[:dependencies]
      self.added_files = hash[:added_files]
      return self
    end

    # Used to initialize the next parser when chained.
    def to_hash
      # TODO: We could probably do this more extensibly with a @data attribute.
      {
        :dependencies => @dependencies,
        :wildcard_dependencies => @wildcard_dependencies,
        :variables => @variables,
        :messages => @messages,
        :added_files => @added_files
      }
    end

    class << self

      def parse_file(directory, filename, output_directory, optimized, &block)
        data, output = {}, nil

        # Parse here
        text   = File.open(File.join(directory, filename), 'r').read()

        parsers = [Hammer::TodoParser]
        parsers += Hammer::Parser.for_filename(filename)

        parsers.each do |parser_class|
          parser = parser_class.new().from_hash(data)

          parser.directory = directory
          parser.output_directory = output_directory
          parser.path      = Pathname.new(File.join(directory, filename)).relative_path_from(Pathname.new(directory)).to_s
          parser.optimized = optimized

          text = parser.parse(text)
          data   = parser.to_hash
        end

        output = text
        block.call(output, data)
      rescue => e
        data = {:error => e.to_s}
        block.call(output, data)
      end
    end

    include Optimizer

  end
end

parsers_path = File.join(File.dirname(__FILE__), '..', 'parsers', '**/*.rb')
Dir[parsers_path].each {|file| require file; }