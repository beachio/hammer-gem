class Hammer
  class Error < Exception
    
    attr_accessor :text, :line_number, :hammer_file
    
    def initialize(text, line_number, hammer_file=nil)
      @text = text
      @line_number = line_number
      @hammer_file = hammer_file
      if hammer_file
        hammer_file.error = self
      end
    end
  end
end