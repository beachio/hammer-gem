module Hammer
  class ApplicationTemplateLineTemplate

    attr_accessor :filename

    def initialize(file, directory)
      # @data = data
      # TODO: Don't
      @file = file
      @directory = directory
    end

    def to_s
      template_html = File.new(File.join(File.dirname(__FILE__), "file.html.erb")).read

      options = @file
      options[:span_class] = span_class
      options[:directory] = @directory

      html = ToErb.new(options).render(template_html)

      # template = ERB.new template_html, nil, "%"
      # html = template.result(binding)

      "\n#{html}"
    end

    def span_class
      classes = []
      classes << "error could_not_compile" if @error_file
      classes << "optimized" if @file[:is_a_compiled_file]
      classes << "error" if @file[:error]
      classes << "include" if @file[:include]
      classes << "include" if File.basename(@file[:output_filename]).start_with? "_"
      classes << "cached" if @file[:from_cache]
      extension = File.extname(@file[:filename])[1..-1]
      classes << extension
      classes << 'image' if ['png', 'gif', 'svg', 'jpg', 'gif'].include? extension

      if extension == "html" || extension == "php"
        classes << "html"
      else
        classes << "success" if @file[:compiled]
        classes << "copied"
      end
      classes.join(" ")
    end

    # def error
    #   "Error"
    # end

    # def path
    #   @file[:filename]
    # end
    # def output_path
    #   @file[:output_filename]
    # end
    # def include?
    #   # @file[:include]
    #   File.basename(@file[:filename])[0] == "_"
    # end
    # def ignored
    #   @file[:ignored]
    # end

    # # extend Forwardable
    # # def_delegators :@hammer_file, :path, :from_cache, :output_filename, :filename,
    #                # :messages, :output_path, :ignored, :include?, :extension, :error

    # def extension

    # end

    # def messages
    #   @file[:messages] || []
    # end

    # def reveal
    #   !@file[:output_filename].start_with?(".")
    # end

    # def show_open_in_browser
    #   !@file[:output_filename].end_with?(".html") && @file[:output_filename]
    # end

    # def show_edit_link
    #   ['.html', ".css", ".js"].include?(File.extname(@file[:filename])) || @file[:output_filename].start_with?(".")
    # end

    # def html
    #   File.extname(@file[:filename]) == ".html"
    # end

    # def compiled
    #   @file[:is_a_compiled_file]
    # end

    # def error_filename
    #   @file[:error_filename]
    # end

    # def error_message
    #   @file[:error]
    # end

    # def error_line
    #   @file[:error_line_number]
    # end
  end
end