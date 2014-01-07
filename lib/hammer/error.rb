module Hammer
  class Error < Exception
    
    attr_accessor :text, :line_number, :original_error
    attr_reader :hammer_file

    def to_s
      @text
    end
    
    def initialize(text, line_number)
      @text = text
      @line_number = line_number
      if hammer_file
        self.hammer_file = hammer_file
      end
    end
    
    def self.from_error(error, hammer_file)
      error_created = new(error.to_s, nil)
      error_created.hammer_file = hammer_file
      error_created.original_error = error
      return error_created
    end
    
    def hammer_file=(hammer_file)
      @hammer_file = hammer_file
      @hammer_file.error = self
    end
    
  end
end