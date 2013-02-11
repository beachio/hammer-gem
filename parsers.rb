class Hammer
  
  class HammerParser

    attr_accessor :hammer_project

    def initialize(hammer_project = nil)
      @text = ""
      @hammer_project = hammer_project if hammer_project
    end

    def text=(text)
      @text = text
    end

    attr_reader :hammer_file
    def hammer_file=(hammer_file)
      @hammer_file = hammer_file

      @text = @hammer_file.raw_text
      @filename = hammer_file.filename
    end
    
    def text
      @text ||= ""
    end
    
    def filename
      @filename ||= @hammer_file.filename
    end
    
    def find_files(filename, extension=nil)
      @hammer_project.find_files(filename, extension)
    end
    
    def find_file(filename, extension=nil)
      find_files(filename, extension)[0]
    end
    
    def replace(regex, &block)
      lines = []
      if text.scan(regex).length > 0
        line_number = 0
        @text = text.split("\n").map { |line| 
          line_number += 1
          line.gsub(regex) { |match| block.call(match, line_number) }
        }.join("\n")
      end
      return
    end

    def parse
      raise "Base HammerParser#parse called"
    end
  end

end