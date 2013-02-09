class Hammer

  class HammerFile
    
    attr_accessor :filename, :hammer_project

    def parser
      Hammer.parser_for_extension(extension)
    end

    # def text=(text)
      # @raw_text ||= text
      # @text = text
    # end

    def text; @text; end
    attr_accessor :raw_text
  

    def extension
      File.extname(@filename)[1..-1]
    end

    def subdirectory
      @subdirectory
    end

    def error(message, line=nil)
      puts "TODO: add_error"
    end

    def warning(message, line=nil)
      puts "TODO: warning"
    end

  end
end