class Hammer
  class Error < Exception
    
    attr_accessor :text, :line_number
    
    def initialize(text, line_number)
      @text = text
      @line_number = line_number
    end
  end
end