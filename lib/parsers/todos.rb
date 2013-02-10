class Hammer
  class TodoParser < HammerParser
    
    attr_accessor :todos, :text
    
    def initialize(text, extension)
      
      @todos = {}
      
      regex = case extension
        when "css"
          /\/\* @todo (.*) \*\//
        when "html"
          /<!-- @todo (.*) -->/
        when "js"
          /\/* @todo (.*) \*\/|\/\/ @todo (.*)/
        when "coffee"
          /# @todo (.*)/
        end
      
      lines = []
      if text.scan(regex).length > 0
        line_number = 0
        text.split("\n").each { |line| 
          line.scan(regex).each do |messages|
            messages.each do |message|
              line_number += 1
              @todos[line_number] = message
            end
          end
          lines << line.gsub(regex, '')
        }
        @text = lines.join("\n")
      end
    end
  end
end