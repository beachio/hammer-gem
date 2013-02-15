class Hammer
  class Error < Exception
    
    attr_accessor :text, :line_number
    attr_reader :hammer_file
    
    def initialize(text, line_number, hammer_file=nil)
      @text = text
      @line_number = line_number
      if hammer_file
        self.hammer_file = hammer_file
      end
    end
    
    def hammer_file=(hammer_file)
      @hammer_file = hammer_file
      @hammer_file.error = self
    end
    
  end
end