class Hammer
  class JSCompressor < Compressor
    def compress
      Uglifier.compile(@text)+"\n;"
    end
  end
  register_compressor JSCompressor, 'js'
end