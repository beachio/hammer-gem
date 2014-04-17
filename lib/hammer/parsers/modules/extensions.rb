module Hammer

  # This class manages the extensions and parsers we're setting.
  require 'singleton'
  class ExtensionMap
    include Singleton
    class << self; attr_accessor :parsers, :extensions_for, :default_parser_for, :parsers_for; end
    
    @extensions_for = {}
    @default_parser_for = {}
    @parsers_for = {}

    # TODO: Make a better way of finding all parsers for an extension.
    def self.all_parsers_for(extension)
      @parsers_for[extension] || []
    end

    def extensions_for(what)
      @extensions_for[what] || []
    end

    @parsers = []
  end

  ## Allows a class to be registered for an extension.

  module ExtensionMapper

    extend Forwardable
    def_delegator ExtensionMap, :extensions_for

    # Fetches "index.html" for "index.haml"
    def output_filename_for(filename)

      extension = File.extname(filename)[1..-1]
      parser    = self.class.for_extension(extension).last

      if parser
        path      = File.dirname(filename)
        basename  = File.basename(filename, ".*")
        extension = parser.finished_extension

        Pathname.new("#{path}/#{basename}.#{extension}").cleanpath.to_s
      else
        filename
      end
    end

    # Fetches related file extensions - ["css"] for "scss" and ["js"] for "coffee"
    def possible_other_extensions_for_extension(extension)
      extensions = []
      parsers = self.class.for_extension(extension)
      parsers.each do |parser|
        ExtensionMap.extensions_for[parser]
        ExtensionMap.extensions_for[parser].each do |extension|
          extensions << extension
        end
      end

      extensions = ExtensionMap.parsers.select {|parser|
        parser.finished_extension == extension
      }.map {|parser|
        begin
          extensions_for[parser]
        rescue => e
          raise e
        end
      }

      extensions.flatten.compact.uniq
    end

    module ClassMethods

      # Utility method - find the final extension for this filename.
      def final_extension_for(extension)
        result = for_extension(extension).last
        return result.finished_extension.to_s if result.respond_to?(:finished_extension)
      end

      ## Finders
      def for_filename(filename)
        for_extension File.extname(filename).gsub(".", "").to_sym
      end

      def for_extension(extension)
        
        parsers = [*ExtensionMap.default_parser_for[extension.to_sym]]
        parsers += ExtensionMap.parsers_for[extension.to_sym] if ExtensionMap.parsers_for[extension.to_sym]
        parsers = parsers.compact

        return [] unless parsers.any?

        parser = parsers.last
        new_extension = nil
        finished_extension = nil

        if parser.respond_to? :finished_extension
          finished_extension = parser.finished_extension
        end

        while new_extension != parser.finished_extension
          new_extension = parser.finished_extension
          if new_extension != extension
            parsers << ExtensionMap.parsers_for[new_extension] # Hammer::Parser.for_extension(new_extension)
          end
        end
        
        return parsers.uniq.flatten.compact
      end

      attr_accessor :finished_extension

      # Input extension
      def accepts(*extensions)
        register_for_extensions [*extensions]
      end

      # Output extension
      def returns(extension)
        @finished_extension = extension
      end

      ## Parser extension registration
      # Register as being the first parser that can handle an extension.
      def register_as_default_for_extensions(extensions)
        ExtensionMap.default_parser_for ||= {}
        extensions = [*extensions]
        extensions.each do |extension|
          ExtensionMap.default_parser_for[extension] = self
        end
      end
      alias_method :register_as_default_for_extension, :register_as_default_for_extensions

      # Add a parser to the series of parsers that can handle an extension.
      def register_for_extensions(extensions)
        extensions = [*extensions]
        ExtensionMap.parsers ||= []
        ExtensionMap.parsers << self
        ExtensionMap.extensions_for ||= {}
        ExtensionMap.parsers_for ||= {}
        extensions.each do |extension|
          ExtensionMap.parsers_for[extension] ||= []
          ExtensionMap.parsers_for[extension] << self
          ExtensionMap.extensions_for[self] ||= []
          ExtensionMap.extensions_for[self] << extension
        end
      end
      alias_method :register_for_extension, :register_for_extensions
    end

    # Better make these class methods available!
    extend ClassMethods
    def self.included(base)
      base.send :extend, ClassMethods
    end

  end
end