require 'forwardable'

module Hammer

  # This class manages the extensions and parsers we're setting.
  require 'singleton'
  class ExtensionMap
    include Singleton
    class << self; attr_accessor :parsers, :extensions_for, :default_parser_for, :parsers_for; end

    @extensions_for ||= {}
    @default_parser_for ||= {}
    @parsers_for ||= {}
    @parsers ||= []

    # # TODO: Make a better way of finding all parsers for an extension.
    # def self.all_parsers_for(extension)
    #   @parsers_for[extension] || []
    # end

    # def extensions_for(what)
    #   @extensions_for[what] || []
    # end
  end

  ## Allows a class to be registered for an extension.

  module Extensions

    extend Forwardable
    def_delegator ExtensionMap, :extensions_for

    # Fetches "index.html" for "index.haml"
    def output_filename_for(filename)
      raise "Filename not given" unless filename
      extension = File.extname(filename)[1..-1]
      parser    = self.class.for_extension(extension).last
      return filename unless parser
      Pathname.new("#{File.dirname(filename)}/#{File.basename(filename, ".*")}.#{parser.finished_extension}").cleanpath.to_s
    end

    # Fetches related file extensions - ["css"] for "scss" and ["js"] for "coffee"
    def possible_other_extensions_for_extension(extension)
      extensions = ExtensionMap.parsers.map {|parser|
        extensions_for[parser] if parser.finished_extension.to_s == extension.to_s
      }.flatten.compact.uniq
      extensions = extensions.map {|extension| extension.to_s }.sort.map {|extension| extension.to_sym }
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

        return [] if extension.nil?
        # raise "Nil extension!" if extension.nil?

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
          ExtensionMap.default_parser_for[extension.to_sym] = self
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

    def parse_file(file, destination_extension)

      # TODO: Ensure this isn't parsing includes when we use parse_file.
      # Careful now! This is the include() method, remember.
      # This method calls to_format(:format) to avoid any final parse stuff.
      # For instance, relative URLs don't want to be parsed inside an include!

      text = ""
      output = read(file)
      Hammer::Parser.for_filename(file).each do |parser_class|
        parser = parser_class.new().from_hash(self.to_hash)

        # p parser_class
        # can_output_to_this_extension = parser.to_format(:coffee) rescue false

        if parser_class.respond_to?(:finished_extension) # && parser_class.finished_extension == destination_extension
          parser.directory = @directory
          parser.output_directory = @output_directory
          parser.input_directory = @input_directory
          parser.path      = Pathname.new(File.join(directory, file)).relative_path_from(Pathname.new(directory)).to_s
          parser.optimized = @optimized
          parser.variables = @variables
          output = parser.parse(output)
          if parser.to_format(destination_extension)
            text = parser.to_format(destination_extension)
          end
          data = parser.to_hash
          @variables = @variables.merge(parser.variables)
        end
      end

      text

      # parser = Hammer::Parser.for_filename(file).last.new()
      # # TODO: This should loop through the parsers for this file until we're at the right extension.
      # path = file
      # if !path.include? @directory
      #   path = File.join(@directory, file)
      # end
      # parser.parse(File.open(path).read())
      # parser.to_format(destination_extension.to_sym)
    end

  end
end