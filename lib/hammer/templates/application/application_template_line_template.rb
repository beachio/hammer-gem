module Hammer
  class ApplicationTemplateLineTemplate

    attr_accessor :filename

    def initialize(options)
      @hammer_file = options[:hammer_file]
      @filename = @hammer_file.filename
    end

    def to_s
      template = ERB.new File.new(File.join(File.dirname(__FILE__), "file.html.erb")).read, nil, "%"
      "\n"+template.result(binding)
    end

    def span_class
      classes = []
      classes << "error could_not_compile" if @error_file
      classes << "optimized" if @hammer_file.is_a_compiled_file
      classes << "error" if @error
      classes << "include" if @include
      classes << "include" if @hammer_file.filename.start_with? "_"
      classes << "cached" if from_cache
      classes << @extension
      classes << 'image' if ['png', 'gif', 'svg', 'jpg', 'gif'].include? @extension
      if @extension == "html" || @extension == "php"
        classes << "html"          
      else
        classes << "success" if @hammer_file.compiled
        classes << "copied"
      end
      classes.join(" ")
    end

    extend Forwardable
    def_delegators :@hammer_file, :path, :from_cache, :output_filename, :messages, :output_path, :ignored, :include?, :extension, :error

    def reveal
      !@filename.start_with?(".")
    end

    def show_open_in_browser
      @filename.end_with?(".html") && output_path
    end

    def show_edit_link
      ['.html', ".css", ".js"].include?(File.extname(@filename)) || @filename.start_with?(".")
    end
    def html
      @hammer_file.extension == "html"
    end

    def compiled
      @hammer_file.is_a_compiled_file || html
    end

    def error_filename
      return error.error_file.filename if error
    end

    # <% # combiled file sources %>
    # <% # sources = @file.source_files.map { |hammer_file| "<a href='#{@file.output_path}' title='#{hammer_file.full_path}'>#{File.basename(hammer_file.filename)}</a>" }a %>

    # def include?
    #   @filename.split()[0] == "_"
    # end

  end
end