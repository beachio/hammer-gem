class Hammer

  class HammerFile
    
    attr_accessor :filename, :full_path, :hammer_project, :compiled_text, :output_filename

    def parser
      send :deprecated
      Hammer.parser_for_extension(extension)
    end
    
    def initialize(options={})
      super()
      @filename = options.delete(:filename) if options[:filename]
      @raw_text = options.delete(:text)
      if options[:hammer_project]
        @hammer_project = options.delete(:hammer_project)
        @hammer_project << self
        
        # if @filename != nil
          # @parser = Hammer.parser_for_extension(self.extension).new(@hammer_project)
          # @parser.hammer_file = self
        # end
      end
    end

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