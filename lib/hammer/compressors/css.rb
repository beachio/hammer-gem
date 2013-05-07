require "sass"
class Hammer
  class CSSCompressor < Compressor
    def parse
      engine = Sass::Engine.new(@text, :syntax => :scss, :style => :compressed)
      ## TODO: make exceptions in required files show up.
      ## TODO: Log errors.
      ## Note: This may not be necessary.
      @text = engine.render()
    end
  end
  register_compressor CSSCompressor, 'css'
end