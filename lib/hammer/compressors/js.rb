class Hammer
  class JSCompressor < Compressor
    def parse
      Uglifier.compile(@text)+"\n;"
    end
  end
  register_compressor JSCompressor, 'js'
end