require 'hammer/parser'
require 'slim'

module Hammer
  class SlimParser < Parser
    accepts :slim
    returns :html
    register_as_default_for_extensions :slim

    def to_format(format)
      if format == :slim
        @text # Variables?
      else
        parse(@text)
      end
    end

    def parse(text, filename=nil)
      @text = text
      text = includes(text, filename)
      text = convert_tags(text)
      text = convert(text)
      text = convert_comments(text)
      text = text[0..-2] if text.end_with?("\n")
      text
    end

    def includes(text, filename)
      lines = text.split("\n")
      line_number = 0
      # lines.each_with_index do |line, line_number|
      while line = lines[line_number]
        if files_from_tag_in_line(line)
          number_of_indents_in_this_line = line[/\A[ |\t]*/].size
          next_line = lines[line_number+1]
          number_of_indents_in_the_next_line = next_line.to_s.number_of_tab_or_space_indents
          is_indented_after_this_line = number_of_indents_in_this_line < number_of_indents_in_the_next_line

          tag = files_from_tag_in_line(line)[1] # line.gsub("/ @include ", "").strip.split(" ")[0]
          raise "trying to include statement without file on
                 #{filename} at line #{line_number + 1}" unless tag

          file = find_file_with_dependency(tag, 'slim') || find_file_with_dependency(tag)
          raise "Includes: File <b>#{h tag}</b> couldn't be found." unless file

          if file.end_with? ".slim"

            # file = File.join(@directory, file)

            # Insert the text of this file as an array.
            lines[line_number] = read(file).array_of_lines_indented_by(line.indentation_string)

            # We only have to change stuff if the next line is indented.
            if is_indented_after_this_line
              last_line = read(file).lines.to_a.last
              lines = indent_from_line(last_line, lines, line_number, read(file).indentation_in_last_line)
            end

            lines = lines.flatten
          elsif line.match /\A\s*\/!?\s*@include\s+([^\s]+)/
            # Insert it as normal. HTML will cover the include.
            lines[line_number].gsub(/!?\s*@include\s+([^\s]+).*/, "<!-- @include #{tag} -->")
          end
        end

        line_number += 1
      end

      lines.join("\n")
    end

    def convert(text)
      Slim::Template.new {
        text
      }.render(Hammer::ContentProxy.new)
    end

    def convert_comments(text)
      text.gsub("&lt;!--", "<!--").gsub("--&gt;", "-->")
    end

    private

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
      line.match(/\A\s*\/!?\s*@include\s+([^\s]+)/) ||
      line.match(/\A\s*<!-+\s+@include\s+([^\s]+)/)
    end

    # convert rails-like helpers to hammer tags
    # include "template" become <!-- @include _?template -->
    def convert_tags(text)
      tags = ['path', 'include', 'stylesheet', 'javascript',
              'todo', 'placeholder']
      regexp = /^(\s*)=\s*(#{tags.join('|')})\s+([^\n]+)/
      text.gsub(regexp) do
        space = Regexp.last_match[1]
        tag = Regexp.last_match[2]
        argument = Regexp.last_match[3].gsub(/[\'\"]/, '').strip
        "#{space}<!-- @#{tag} #{argument} -->"
      end
    end
  end
end