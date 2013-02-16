require "rubygems"
require "v8"

class Hammer
  class JSCompressor < Compressor
    def parse
      Uglifier.compile(@text)
    end
  end
  register_compressor JSCompressor, 'js'
end