class Hammer
  class TodoParser < HammerParser
    
    def regex
      case @format
      when 'css'
        /\/* @todo (.*?)\*\//
      when 'scss', 'sass'
        /\/\/ @todo (.*)|\/\* @todo (.*) \*\//
      when 'html', 'md'
        /<!-- @todo (.*?) -->/
      when 'coffee'
        /# @todo (.*)/
      when 'jst', 'js'
        /\/* @todo (.*?) \*\/|\/\/ @todo (.*)/
      when 'haml'
        /\/ @todo (.*)/
      end
    end
    
    def parse
      
      @text = @hammer_file.raw_text
      @format = File.extname(@hammer_file.filename)[1..-1]
      
      results = {}
      return {} if !regex or !@text.match(regex)
      
      @text.split("\n").each_with_index do |line, line_number|
        line_number += 1
        line.scan(regex).each do |messages|
          messages.compact.each do |message|
            results[line_number] ||= []
            results[line_number] << message.strip
          end
        end
      end
      
      return results
      
    rescue
      []
    end
  end
end