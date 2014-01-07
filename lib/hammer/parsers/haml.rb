require "haml"

class String
  def number_of_tab_or_space_indents
    self[/\A[ |\t]*/].size
  end

  def indentation_character
    if number_of_tab_or_space_indents > 0
      split("")[0]
    else
      ""
    end
  end

  def indentation_in_last_line
    lines.map(&:chomp)[-1][/\A[ |\t]*/].size
  end

  def indentation_string
    indentation_character * number_of_tab_or_space_indents
  end

  def array_of_lines_indented_by(letters_to_indent_by)
    lines.map { |line| "#{letters_to_indent_by}#{line}" }
  end

end

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

module Hammer
    
  class HAMLParser < Parser

    def self.finished_extension
      "html"
    end

    def to_html
      parse
    end
    
    def includes
      return unless @hammer_project
      
      lines = text_as_lines
      
      line_number = 0
      # lines.each_with_index do |line, line_number|
      while line = lines[line_number]
        
        if line.match /[\s-]*\/ @include (.*)/
          
          number_of_indents_in_this_line = line[/\A[ |\t]*/].size

          next_line = lines[line_number+1]
          number_of_indents_in_the_next_line = next_line.number_of_tab_or_space_indents
          is_indented_after_this_line = number_of_indents_in_this_line < number_of_indents_in_the_next_line

          tag = files_from_tag_in_line(line)[0] # line.gsub("/ @include ", "").strip.split(" ")[0]

          file = find_file(tag, 'html')
          
          raise "Includes: File <b>#{h tag}</b> couldn't be found." unless file
          
          if file.extension == "haml"

            # Insert the text of this file as an array.
            lines[line_number] = file.raw_text.array_of_lines_indented_by(line.indentation_string)

            # We only have to change stuff if the next line is indented.
            if is_indented_after_this_line
              last_line = last_line = file.raw_text.lines.to_a.last
              lines = indent_from_line(last_line, lines, line_number, file.raw_text.indentation_in_last_line)
            end

            lines = lines.flatten
          else
            # Insert it as normal. HTML will cover the include.
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

    def text_as_lines
      @hammer_file.raw_text.split("\n")
    end

    # This function takes an array of lines, and an original line that has been replaced with input.
    # From there, it indents any line after the inserted line, by the same amount of indentation as
    # the last line that was inserted.
    def indent_from_line(line, lines, line_number, number_of_indents)

      indents_at_this_line = line.to_s.number_of_tab_or_space_indents
      
      # Here we have an include that's followed by an indented line.
      # Since we're including HAML inside HAML, we have to shuffle everything downwards until things fit.
      # So we skip forward until we find a line with the same number of indents,
      # and indent these lines as we go.

      i = line_number+1

      while i < lines.length

        future_line = lines[i]
        indents_at_the_future_line = future_line.to_s.number_of_tab_or_space_indents
        next_line_is_indented = indents_at_the_future_line > indents_at_this_line

        break unless next_line_is_indented

        # Tabs or spaces?
        indent_character = future_line.indentation_character
        # Indent the line by the 
        letters_to_indent_by = indent_character * number_of_indents

        # Replace the line!
        # future_line = "#{letters_to_indent_by}#{future_line}"
        lines[i] = letters_to_indent_by + lines[i]

        i += 1
      end

      return lines
    end

    def files_from_tag_in_line(line)
      [line.gsub("/ @include ", "").strip.split(" ")[0]]
    end
    
    def convert(text)
      Haml::Engine.new(text).to_html
    end
    
    def convert_comments(text)
      text.gsub("&lt;!--", "<!--").gsub("--&gt;", "-->")
    end
    
  end
  Hammer::Parser.register_for_extensions HAMLParser, ['haml']
  Hammer::Parser.register_as_default_for_extensions HAMLParser, ['haml']

end