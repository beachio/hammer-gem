# Parse todos for all the formats!

class Hammer
  
  class TodoParser < HammerParser
    
    attr_accessor :todos, :text
    
    def initialize(text, extension)
      
      @todos = {}
      
      regex = case extension
      when "css"
        /\/\* @todo (.*?) \*\//
      when "scss", "sass", "js"
        /\/\* @todo (.*?) \*\/|\/\/ @todo (.*)/
      when "html"
        /<!-- @todo (.*?) -->/
      when "coffee"
        /# @todo (.*)/
      end
      
      lines = []
      if text =~ regex
        line_number = 0
        text.split("\n").each { |line| 
          line_number += 1
          if line =~ regex
            @todos[line_number] = line.scan(regex).flatten.compact
          end
          lines << line.gsub(regex, '')
        }
        @text = lines.join("\n")
      end
    end
  end
end