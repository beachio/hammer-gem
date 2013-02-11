require "include"

class Hammer
  
  class HammerParser

    def initialize(hammer_project = nil)
      @text = ""
      @hammer_project = hammer_project if hammer_project
    end

    def text=(text)
      @text = text
    end
    
    def text
      if @hammer_file && @text.to_s == ""
        @hammer_file.raw_text.to_s
      else
        @text
      end
    end
    
    def filename
      if @filename
        return @filename
      elsif @hammer_file 
        return @hammer_file.filename
      end
    end
    
    def find_files(filename, extension=nil)
      @hammer_project.find_files(filename, extension)
    end
    
    def find_file(filename, extension=nil)
      find_files(filename, extension)[0]
    end
    
    attr_accessor :hammer_file, :hammer_project

    def replace(regex, &block)
      lines = []
      if self.text.scan(regex).length > 0
        line_number = 0
        text.split("\n").each { |line| 
          line_number += 1
          lines << line.gsub(regex) { |match| 
            block.call(match, line_number)
          }
        }
        @text = lines.join("\n")
      end
      return
    end

    def parse
      raise "Base HammerParser#parse called"
    end
  end

end