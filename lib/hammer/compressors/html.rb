class Hammer
  class HTMLCompressor < Compressor
    def parse()
      @text
    end
  end
  register_compressor HTMLCompressor, 'html'
end