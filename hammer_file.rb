class Hammer

  class HammerFile
    
    def hammer_project=(project)
      @hammer_project = project
    end
    def hammer_project
      @hammer_project
    end

    def parser
      Hammer.parser_for(@extension)
    end

    def text=(text)
      @raw_text ||= text
      @text = text
    end

    def text
      @text
    end

    def raw_text
      @raw_text
    end

    def raw_text=(text)
      @raw_text = text
    end

    def raw_text
      @raw_text
    end

    def filename=(filename)
      @filename = filename
      @extension = File.extname(filename)[1..-1]
    end

    def filename
      @filename
    end

    def extension
      @extension
    end

    def extension=(new_extension)
      @extension = new_extension
    end

    def subdirectory
      @subdirectory
    end

    def set_variable(name, value)
    end

    def variables
      @variables ||= {}
    end

    def error(message, line=nil)
      puts "TODO: add_error"
    end

    def warning(message, line=nil)
      puts "TODO: warning"
    end

  end
end