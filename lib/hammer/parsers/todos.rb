module Hammer
  class TodoParser < Parser

    if !defined? CSS_REGEX
      CSS_REGEX = /\/* @(?:todo|TODO) (.*?)\*\//
      SCSS_SASS_REGEX = /\/\/ @(?:todo|TODO) (.*)|\/\* @(?:todo|TODO) (.*) \*\//
      HTML_REGEX = /<!-- @(?:todo|TODO) (.*?) -->/
      COFFEE_REGEX = /# @(?:todo|TODO) (.*)/
      JST_JS_REGEX = /\/* @(?:todo|TODO) (.*?) \*\/|\/\/ @(?:todo|TODO) (.*)/
      HAML_REGEX = /\/ @(?:todo|TODO) (.*)/
    end
    
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
      @format ||= File.extname(@path)[1..-1]
    end
    
    def parse(text)
      @text = text
      
      results = {}
      # return "" unless @text
      return @text if !regex or !@text.match(regex)
      
      text = replace(text, regex) do |message, line_number|
        message = message.scan(regex).flatten.first
        (results[line_number] ||= []) << message.strip
        message
      end

      # @text.split("\n").each_with_index do |line, line_number|
      #   line_number += 1
      #   line.scan(regex).each do |messages|
      #     messages.flatten.compact.each do |message|
      #       results[line_number] ||= []
      #       results[line_number] << message.strip
      #     end
      #   end
      # end

      results.each do |line, message|
        @todos ||= {}
        @todos[line] ||= []
        @todos[line] = message
      end
      
      return @text
    end
  end
end