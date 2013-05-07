class Hammer

  class Compressor
    def initialize(text)
      @text = text
    end
    
    # This block wraps each compressor's compress() function to allow for errors.
    # In future it should rescue() to allow for errors to propagate out and be formatted.
    # For now it does not. 
    def parse
      compress()
    end
    
    def compress
      raise "Base Hammer::Compressor#compress was called. Please override compress() in your Hammer compressor."
    end
    
  end
    
  def self.register_compressor(compressor_class, format)
    @@after_compilers ||= {}
    @@after_compilers[format] ||= []
    @@after_compilers[format] << compressor_class
  end
  
end