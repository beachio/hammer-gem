require 'lib/hammer/parsers/extensions'

module Hammer
  class Parser

    include ExtensionMapper

    def parse(text)
      return text
    end

    def from_json(json)
      # ...
      # TODO: What are we doing here?
    end

    def to_json
      {
        dependencies: [],
        wildcard_dependencies: []
      }
    end

  end
end