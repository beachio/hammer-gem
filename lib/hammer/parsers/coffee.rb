require 'hammer/parser'

module Hammer
  class CoffeeParser < Parser

    accepts :coffee
    returns :js
    register_as_default_for_extensions :coffee
    attr_accessor :to_coffeescript

    def to_format(format)
      case format
      when :js
        parse(@text)
      when :coffee
        @text
      end
    end

    def parse(text=nil, filename=nil,test=nil)
      text ||= @text
      @text ||= text
      @filename ||= filename

      text = includes text
      if !optimized && @filename
        text = compile_with_source_map(text)
      else
        text = CoffeeScript.compile text
      end
      replace_includes text
    rescue ExecJS::ProgramError, ExecJS::RuntimeError => error
      line = error.message.scan(/on line ([0-9]*)/).flatten.first.to_s rescue nil
      message = error.message.split("Error: ")[1]
      message = "Coffeescript Error: #{message}"
      # TODO: Do something with line!
      raise message
    end
    alias_method :to_javascript, :parse

  private

    def replace_includes(text)
      return replace(text, /__hammer_include\((.*)\)/) do |invocation, line_number|
        file = invocation.gsub("__hammer_include(", "")[0..-2]
        "/* @include #{file} */"
      end
    end

    def includes(text)
      lines = []
      return replace(text, /# @include (.*)/) do |invocation, line_number|
        tags = invocation.gsub("# @include ", "").strip.split(" ")
        a = tags.map do |tag|

          file = find_file(tag, 'coffee')
          add_dependency(file)

          raise "File not found: <strong>#{h tag}</strong>" unless file

          # p file
          # p Hammer::Parser.for_filename(file).last
          # parser = Hammer::Parser.for_filename(file).last

          # TODO: to_format(:coffee)
          # puts "Parsing! #{parser}"
          # if parser.respond_to? :to_format
          if file.end_with? '.coffee'
            # parser.parse(read(file))
            # parser.to_coffeescript(read(file))
            # parser.to_format(:coffee)
            parse_file(file, :coffee)
            # require 'byebug'; byebug
          else
            "__hammer_include(#{tag})"
          end
        end
        a.compact.join("\n")
      end
    end

    def compile_with_source_map(text)
      map_path = @filename.gsub(/[^\.]+$/, 'js.map')
      result = CoffeeScript.compile(
        text,
        {
          sourceMap: true,
          inline: true,
          sourceFiles: ["/#{@filename}"]
        }
      )
      File.open("#{@output_directory}/#{map_path}", 'w') do |f|
        f.write(result['v3SourceMap'])
      end
      result['js'] += "\n//# sourceMappingURL=#{File.basename(map_path)}"
    end

  end
end
