module Hammer
  class TodoParser < Parser

    CSS_REGEX = /\/* @(?:todo|TODO) (.*?)\*\//
    SCSS_SASS_REGEX = /\/\/ @(?:todo|TODO) (.*)|\/\* @(?:todo|TODO) (.*) \*\//
    HTML_REGEX = /<!-- @(?:todo|TODO) (.*?) -->/
    COFFEE_REGEX = /# @(?:todo|TODO) (.*)/
    JST_JS_REGEX = /\/* @(?:todo|TODO) (.*?) \*\/|\/\/ @(?:todo|TODO) (.*)/
    HAML_REGEX = /\/ @(?:todo|TODO) (.*)/
    
    def regex
      case format
      when 'css'
        CSS_REGEX
      when 'scss', 'sass'
        SCSS_SASS_REGEX
      when 'html', 'md'
        HTML_REGEX
      when 'coffee'
        COFFEE_REGEX
      when 'jst', 'js'
        JST_JS_REGEX
      when 'haml'
        HAML_REGEX
      end
    end

    def format
      @format ||= File.extname(@hammer_file.filename)[1..-1]
    end
    
    def parse
      @text = @hammer_file.raw_text
      
      results = {}
      return {} if !regex or !@text.match(regex)
      
      @text.split("\n").each_with_index do |line, line_number|
        line_number += 1
        line.scan(regex).each do |messages|
          messages.flatten.compact.each do |message|
            results[line_number] ||= []
            results[line_number] << message.strip
          end
        end
      end
      
      return results
    end
  end
end