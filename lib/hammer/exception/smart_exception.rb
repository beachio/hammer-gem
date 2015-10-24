module Hammer
  class SmartException < StandardError
    attr_accessor :message, :description, :source_path, :line, :input_directory

    def initialize(message = nil, description = {}, *source_args)
      @message = message || 'Unknown error'
      @description = description
      return unless source_args.any?
      @source_path = source_args[0]
      @line = source_args[1]
      @input_directory = source_args[2]
    end

    def description
      @description[:text]
    end

    def description_list
      @description[:list] || []
    end

    def relative_source_path
      @source_path.sub("#{@input_directory}/", '') if @source_path
    end

    def extension
      File.extname(@source_path)[1..-1] if @source_path
    end

    def extracted_source
      return nil unless @source_path && @line
      source_text = File.read(@source_path) rescue nil
      if source_text
        source = source_text.lines
        extracted = {}
        (@line - 4..@line + 2).to_a.each do |line_number|
          extracted[line_number + 1] = source[line_number]
        end
        extracted
      end
    end
  end
end
