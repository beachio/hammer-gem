require "sass"
class Hammer
  class CSSCompressor < Compressor
    def parse
      Sass::Engine.new(@text, :syntax => :scss, :style => :compressed).render()
    end
  end
  register_compressor CSSCompressor, 'css'
end