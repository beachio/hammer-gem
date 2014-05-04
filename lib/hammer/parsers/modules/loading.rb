module Hammer
  class Parser
    def self.load_parsers_from_directory(directory)
      Dir[directory+"/*_parser.rb"].each do |parser|
        require parser
      end
    end
  end
end