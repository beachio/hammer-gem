module Hammer

  # This class manages the extensions and parsers we're setting.
  require 'singleton'
  class HammerMapper
    include Singleton
    class << self; attr_accessor :parsers, :extensions_for, :default_parser_for, :parsers_for; end
    
    @extensions_for = {}
    @default_parser_for = {}
    @parsers_for = {}
    @parsers = []
  end

  ## Allows a class to be registered for an extension.

  module ExtensionMapper

    module ClassMethods

      def final_extension_for(extension)
        result = for_extension(extension).last
        return result.finished_extension.to_s if result.respond_to?(:finished_extension)
      end

      # Fetch all extensions for a type of parser
      def extensions_for(parser_class)
        HammerMapper.extensions_for[parser_class]
      end

      def for_extension(extension)
        parser = HammerMapper.default_parser_for[extension]

        if HammerMapper.parsers_for && HammerMapper.parsers_for[extension] && !parser
          parser = HammerMapper.parsers_for[extension][0]
        end
        
        return [] unless parser
        
        parsers = [parser]
        if HammerMapper.parsers_for[extension]
          parsers += HammerMapper.parsers_for[extension]
          parser = parsers.last
        end
        
        new_extension = nil
        
        finished_extension = nil
        if parser.respond_to? :finished_extension
          finished_extension = parser.finished_extension
        end

        while new_extension != parser.finished_extension
          new_extension = parser.finished_extension
          if new_extension != extension
            parsers << HammerMapper.parsers_for[new_extension] # Hammer::Parser.for_extension(new_extension)
          end
        end
        
        return parsers.uniq.flatten
      end
      
      attr_accessor :finished_extension

      def accepts(extensions)
        register_for_extensions extensions
      end

      def returns_extension(extension)
        @finished_extension = extension
      end
      # Register as being the first parser that can handle an extension.
      def register_as_default_for_extensions(extensions)
        HammerMapper.default_parser_for ||= {}
        extensions = [*extensions]
        extensions.each do |extension|
          HammerMapper.default_parser_for[extension] = self
        end
      end
      alias_method :register_as_default_for_extension, :register_as_default_for_extensions

      # Add a parser to the series of parsers that can handle an extension.
      def register_for_extensions(extensions)
        extensions = [*extensions]
        HammerMapper.parsers ||= []
        HammerMapper.parsers << self
        HammerMapper.extensions_for ||= {}
        HammerMapper.parsers_for ||= {}
        extensions.each do |extension|
          HammerMapper.parsers_for[extension] ||= []
          HammerMapper.parsers_for[extension] << self
          HammerMapper.extensions_for[self] ||= []
          HammerMapper.extensions_for[self] << extension
        end
      end
      alias_method :register_for_extension, :register_for_extensions
    end

    def self.included(base)
      base.send :extend, ClassMethods
    end

  end
end