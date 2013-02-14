class Hammer

  class Compressor
    def initialize(text)
      @text = text
    end
  end
  
  def self.register_compressor(compressor_class, format)
    @@after_compilers ||= {}
    @@after_compilers[format] ||= []
    @@after_compilers[format] << compressor_class
  end
  
end