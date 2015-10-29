require 'parsers/modules/extensions'
require 'parsers/modules/variables'
require 'parsers/modules/optimizer'
require 'parsers/modules/adding_files'
require 'parsers/modules/finding_files'
require 'parsers/modules/dependencies'
require 'parsers/modules/replacement'
require 'parsers/modules/paths'
require 'parsers/modules/loading'

module Hammer
  class Parser

    #TODO: Do we move dependencies into a module?
    attr_accessor :text
    attr_accessor :dependencies, :wildcard_dependencies
    attr_accessor :error_line, :error_file
    attr_accessor :path, :directory, :variables, :messages, :todos, :input_directory
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
      @variables = options[:variables] || {}
      @directory = options[:directory] || Dir.mktmpdir()
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

    def parse(text="", filename=nil)
      return text
    end

    # Used when creating a parser, to initialize variables from the last parser.
    def from_hash(hash)
      self.variables = hash[:variables] if hash[:variables]
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

      def parse_added_file(input_directory, temporary_directory, filename, output_directory, optimized, &block)
        # We return a hash and some text!
        data    = {:filename => filename}
        text    = File.open(File.join(temporary_directory, filename), 'r').read()
        parsers = [Hammer::TodoParser] + Hammer::Parser.for_filename(filename)

        parsers.each do |parser_class|

          # Parser initialization
          parser                  = parser_class.new().from_hash(data)
          parser.directory        = input_directory
          parser.input_directory  = input_directory
          parser.output_directory = output_directory
          parser.path             = Pathname.new(File.join(input_directory, filename)).relative_path_from(Pathname.new(input_directory)).to_s
          parser.optimized        = optimized

          begin
            text = parser.parse(text, filename)
          rescue RuntimeError => e
            # Set the error up and then get out of here!
            # This doesn't get saved to the parser, but that doesn't really matter.
            data.merge!({:error_line => parser.error_line}) if parser.error_line
            data.merge!({:error_file => parser.error_file}) if parser.error_file
            data.merge!({:error => e.to_s})

            # No, we don't raise this error here. We just put it in :data.
            # raise e
            # TODO: Maybe a DEBUG would help with this!
          ensure
            data.merge!(parser.to_hash)
          end
        end

        block.call(text, data)
      end

      def parse_file(directory, filename, output_directory, optimized, &block)
        # We return a hash and some text!
        data    = {:filename => filename}
        text    = File.open(File.join(directory, filename), 'r').read()
        parsers = [Hammer::TodoParser] + Hammer::Parser.for_filename(filename)

        parsers.each do |parser_class|
          # Parser initialization
          parser                  = parser_class.new().from_hash(data)
          parser.directory        = directory
          parser.input_directory  = directory
          parser.output_directory = output_directory
          parser.path             = Pathname.new(File.join(directory, filename)).relative_path_from(Pathname.new(directory)).to_s
          parser.optimized        = optimized

          begin
            text = parser.parse(text, filename)
          rescue RuntimeError => e
            # Set the error up and then get out of here!
            # This doesn't get saved to the parser, but that doesn't really matter.
            data.merge!({:error_line => parser.error_line}) if parser.error_line
            data.merge!({:error_file => parser.error_file}) if parser.error_file
            data.merge!({:error => e.to_s})

            # No, we don't raise this error here. We just put it in :data.
            # raise e
            # TODO: Maybe a DEBUG would help with this!
          ensure
            data.merge!(parser.to_hash)
          end
        end

        block.call(text, data)
      end
    end

    include Optimizer
  end
end

if $root_dir
  parsers_path = File.join($root_dir, 'lib', 'hammer', 'parsers', '**/*.rb')
else
  parsers_path = File.join(File.dirname(__FILE__), '..', 'parsers', '**/*.rb')
end
Dir[parsers_path].each {|file| require file; }
