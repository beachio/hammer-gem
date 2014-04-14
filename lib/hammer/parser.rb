require 'lib/hammer/parsers/extensions'

module Hammer
  class Parser

    attr_accessor :optimized, :path, :directory, :variables
    include ExtensionMapper

    def parse(text)
      return text
    end

    # Used when creating a parser, to initialize variables from the last parser.
    def from_json(json)
      self.variables = json[:variables]
    end

    # Used to initialize the next parser when chained.
    def to_json
      {
        dependencies: [],
        wildcard_dependencies: [],
        variables: @variables
      }
    end

  end
end