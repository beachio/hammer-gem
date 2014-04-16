require 'lib/hammer/parsers/modules/extensions'
require 'lib/hammer/parsers/modules/variables'
require 'lib/hammer/parsers/modules/optimizer'
require 'lib/hammer/parsers/modules/file_adder'

module Hammer
  class Parser

    #TODO: Do we move dependencies into a module?
    attr_accessor :text
    attr_accessor :dependencies, :wildcard_dependencies
    attr_accessor :path, :directory, :variables, :messages
    attr_accessor :added_files
    include ExtensionMapper
    include Variables
    include FileAdding

    def filename
      path
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
        dependencies: @dependencies,
        wildcard_dependencies: @wildcard_dependencies,
        variables: @variables,
        messages: @messages,
        added_files: @added_files
      }
    end

    class << self

      def parse_file(directory, filename, output_directory, optimized, &block)
        data, output = {}, nil

        # Parse here
        text   = File.open(File.join(directory, filename), 'r').read()
        Hammer::Parser.for_filename(filename).each do |parser_class|
          parser = parser_class.new().from_hash(data)

          parser.directory = directory
          parser.output_directory = output_directory
          parser.path      = Pathname.new(File.join(directory, filename)).relative_path_from(Pathname.new(directory))
          parser.optimized = optimized

          text = parser.parse(text)
          data   = parser.to_hash
        end

        output = text
        block.call(output, data)
      end
    end

    include Optimizer

  end
end

parsers_path = File.join(File.dirname(__FILE__), 'parsers', '**/*.rb')
Dir[parsers_path].each {|file| require file; puts file }