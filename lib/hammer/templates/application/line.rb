module Hammer
  class ApplicationTemplateLineTemplate

    attr_accessor :filename

    def initialize(data, directory)
      @data = data
      @directory = directory
    end

    def to_s
      template_html = File.new(File.join(File.dirname(__FILE__), "file.html.erb")).read
      options = @data
      options[:span_class] = span_class
      options[:directory] = @directory
      html = ToErb.new(options).render(template_html)
      "\n#{html}"
    end

    def span_class
      classes = []
      classes << "error could_not_compile" if @data[:error_file]
      classes << "optimized" if @data[:is_a_compiled_file]
      classes << "error" if @data[:error]

      classes << "include" if @data[:include]
      classes << "include" if File.basename(@data[:output_filename]).start_with? "_"

      classes << "cached" if @data[:from_cache]

      extension = File.extname(@data[:filename])[1..-1]
      classes << extension
      classes << 'image' if ['png', 'gif', 'svg', 'jpg', 'gif'].include? extension

      if extension == "html" || extension == "php"
        classes << "html"
      else
        classes << "success" if @data[:compiled]
        classes << "copied"
      end
      classes.join(" ")
    end
  end
end