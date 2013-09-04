require "haml"

class HAMLHelper
  def initialize(instance)
    @instance = instance
  end
  
  def path(tag)
    file = @instance.find_file(tag)
    raise "Path tags: <b>#{h tag}</b> couldn't be found." unless file
    @instance.path_to(file)
  end
end

class Hammer
    
  class HAMLParser < HammerParser

    def self.finished_extension
      "html"
    end

    def to_html
      parse
    end
    
    def as_lines
      @text.split("\n")
    end
    
    def includes
      return unless @hammer_project
      
      lines = @text.split("\n")
      
      line_number = 0
      # lines.each_with_index do |line, line_number|
      while line = lines[line_number]
        
        if line.match /[\s-]*\/ @include (.*)/
          
          number_of_indents_in_this_line = line[/\A[ |\t]*/].size
          next_line = lines[line_number+1]
          puts "Line after include:"
          puts next_line
          number_of_indents_in_the_next_line = next_line[/\A[ |\t]*/].size 
          indented_after_this_line = number_of_indents_in_this_line < number_of_indents_in_the_next_line
          
          tag = line.gsub("/ @include ", "").strip.split(" ")[0]
          file = find_file(tag, 'html')
          
          raise "Includes: File <b>#{h tag}</b> couldn't be found." unless file
          
          if file.extension == "haml"
            
            letters_to_indent_by = line.split("")[0] * line[/\A[ |\t]*/].size
            lines[line_number] = file.raw_text.split("\n").map {|line| letters_to_indent_by + line }
            
            if indented_after_this_line
              indents_at_this_line = line[/\A[ |\t]*/].size
              included_file_last_line_indentation = file.raw_text.split("\n")[-1][/\A[ |\t]*/].size
              
              i = line_number + 1
              
              while i < lines.length
                if lines[i][/\A[ |\t]*/].size > indents_at_this_line
                  
                  letters_to_indent_by = line.split("")[0] * line[/\A[ |\t]*/].size
                  
                  lines[i] = letters_to_indent_by + lines[i]
                end
                i+=1
              end
            else
              
            end
            lines = lines.flatten
          else
            lines[line_number] = "<!-- @include #{tag} -->"
          end
          
        end
        
        line_number += 1
      end
      
      @text = lines.join("\n")
    end
     
    def to_haml
      @raw_text
    end
    
    def parse
      includes()
      @text = convert(text)
      @text = convert_comments(text)
    end
    
    private
    
    def convert(text)
      # base = HAMLHelper.new(self)
      # Haml::Engine.new(text).render(base)
      Haml::Engine.new(text).to_html
    end
    
    def convert_comments(text)
      text.gsub("&lt;!--", "<!--").gsub("--&gt;", "-->")
    end
    
  end
  register_parser_for_extensions HAMLParser, ['haml']
  register_parser_as_default_for_extensions HAMLParser, ['haml']

end