class Hammer
  class Error < Exception
    
    attr_accessor :text, :line_number, :original_error
    attr_reader :hammer_file
    
    def initialize(text, line_number)
      @text = text
      @line_number = line_number
      if hammer_file
        self.hammer_file = hammer_file
      end
    end
    
    def self.from_error(error)
      hammer_file = new(error.to_s, nil)
      hammer_file.original_error = error
    end
    
    def hammer_file=(hammer_file)
      @hammer_file = hammer_file
      @hammer_file.error = self
    end
    
  end
end