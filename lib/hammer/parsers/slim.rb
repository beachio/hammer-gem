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
      text = convert_tags(text)
      text, map = includes(text, filename)
      begin
        text = convert(text, filename)
      rescue Hammer::SmartException => e
        trace_line = match_line_from_backtrace(e.backtrace)
        file, line = real_source_and_line(map, trace_line)
        e.source_path = @input_directory + '/' + file
        e.line = line
        e.input_directory = @input_directory
        raise e
      rescue Exception => e
        raise e unless e.message.match('TEMPLATE')
        message = e.message.sub(/\(__TEMPLATE__\):\d+:\s*/, '')
        ex = SmartException.new(message, text: message)
        trace_line = match_line_from_backtrace([e.message])
        file, line = real_source_and_line(map, trace_line)
        ex.source_path = @input_directory + '/' + file
        ex.line = line
        ex.input_directory = @input_directory
        raise ex
      end
      text = convert_comments(text)
      text = text[0..-2] if text.end_with?("\n")
      text
    end

    def includes(text, filename, level = 0, map = {}, offset = 0)
      fail "Circular include: <b>#{h filename}</b> was included about 10 times!." if level > 10

      lines = text.split("\n")
      processed_lines = []
      line_number = 0
      original_offset = offset
      while line = lines[line_number]
        if include_match = file_from_tag_in_line(line)
          indentation = include_match[1]
          tag = include_match[2]
          file = find_file_with_dependency(tag, 'slim') || find_file_with_dependency(tag)
          raise "Includes: File <b>#{h tag}</b> couldn't be found." unless file

          if file.end_with? ".slim"

            # update map
            map[(last_position(map) + 1)..offset + line_number - 1] = {
              file: filename
            } if offset + line_number > 0 # only if at least one line past
            # parse included includes
            include_text = read(file)
            include_text = convert_tags(include_text)
            include_text, map = includes(include_text, file,
                                         level + 1, map,
                                         line_number + offset)

            # Insert the text of this file as an array.
            indented_array = include_text.split("\n").map do |string|
              "#{indentation}#{string}"
            end

            offset += indented_array.count - 1
            processed_lines.concat(indented_array)
          else
            # Insert it as normal. HTML will cover the include.
            processed_lines << "#{indentation}<!-- @include #{tag} -->"
          end
        else
          processed_lines << line
        end
        line_number += 1
      end

      map[last_position(map) + 1..(original_offset + processed_lines.count - 1)] = {
        file: filename,
        offset: offset
      }
      [processed_lines.join("\n"), map]
    end

    def convert(text, filename = nil)
      Slim::Template.new {
        text
      }.render(Hammer::ContentProxy.new())
    end

    def convert_comments(text)
      text.gsub("&lt;!--", "<!--").gsub("--&gt;", "-->")
    end

    private

    def match_line_from_backtrace(backtrace)
      line = backtrace.find{ |x| x.match('TEMPLATE') }
      match = line.match(/:(\d+)/)
      match ? match[1].to_i : nil
    end

    def real_source_and_line(map, line)
      mapped = map.find{|k, v| k.include? line}
      file = mapped[1][:file]
      line = line - mapped[0].first
      [file, line]
    end

    def last_position(map)
      (map.keys.last || (-1..-1)).last
    end

    def file_from_tag_in_line(line)
      line.match(/\A(\s*)\/!?\s*@include\s+([^\s]+)/) ||
        line.match(/\A(\s*)<!-+\s+@include\s+([^\s]+)/)
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