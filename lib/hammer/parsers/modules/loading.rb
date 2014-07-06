## This class loads all parsers from a given directory.
## This is used when a project has Hammer extensions in it.

module Hammer
  class Parser
    def self.load_parsers_from_directory(directory, pattern)
      Dir[File.join(directory, pattern)].each do |parser|
        require parser
      end
    end
  end
end