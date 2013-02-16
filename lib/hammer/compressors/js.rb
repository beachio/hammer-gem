begin
  require "rubygems"
  require "v8"
rescue
end

class Hammer
  class JSCompressor < Compressor
    def parse
      t = Time.now
      x = Uglifier.compile(@text)
      puts "Time for compiling JS = #{Time.now - t}"
      return x
    end
  end
  register_compressor JSCompressor, 'js'
end