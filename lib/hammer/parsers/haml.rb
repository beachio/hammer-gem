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
    
    def includes
      return unless @hammer_project
      
      while text.match /[\s-]*\/ @include (.*)/
        
        lines = []
        replace(/[\s-]*\/ @include (.*)/) do |line, line_number|
          
          tags = line.gsub("/ @include ", "").strip.split(" ")
          number_of_indents_in_this_line = line[/\A[ |\t]*/].size
          number_of_indents_in_the_next_line = @text.split("\n")[line_number][/\A[ |\t]*/].size rescue -1
          indented_after_this_line = number_of_indents_in_this_line < number_of_indents_in_the_next_line

          tags.map do |tag|
            
            if (tag.start_with? "$")
              variable_value = variables[tag[1..-1]]
              
              if !variable_value
                raise "Includes: Can't include <b>#{h tag}</b> because <b>#{h tag}</b> isn't set."
              end
              
              tag = variable_value
            end
            
            file = find_file(tag, 'html')
            
            if file
              if file.extension == "haml" && !indented_after_this_line
                
                indentation = line.split("/")[0].length
                char = line.split("/")[0].split("")[0]
                text = file.raw_text
                if char
                  text = text.split("\n").map {|line|  (char * indentation) + line }.join("\n")
                end
                text
              else
                if file.extension == "haml"
                  file.raw_text
                else
                  "<!-- @include #{tag} -->"
                end
              end
            else
              raise "Includes: File <b>#{h tag}</b> couldn't be found."
            end
          end.compact.join("\n")
        end
      end
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