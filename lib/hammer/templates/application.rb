# encoding: utf-8
$LANG = "UTF-8"
require 'lib/hammer/templates/base'

# module Hammer
#   class ErrorTemplate < Template
#     def initialize(object)
#       @object = object
#     end
#     def to_s(error_object)
#       "<div class='build-error'>
#         <span>Error while building!</span>
#         <span>Error details:</span>
#         <p>#{error_object}</p>
#         <p>#{error_object && error_object.backtrace}</p>
#       </div>"
#     end
#   end
# end

module Hammer

  class ApplicationTemplate < Template

    attr_accessor :files, :input_directory, :output_directory

    def to_s
      return @text if @text
      application_template_path = File.join(File.dirname(__FILE__), "application", "application.html.erb")
      template_contents = File.new(application_template_path).read
      template = ERB.new(template_contents, nil, "%")
      @text = template.result(binding)
    end

    def line_for(options)
      template_html = File.new(File.join(File.dirname(__FILE__), "application", "file.html.erb")).read
      options[:span_class] = span_class(options)
      options[:output_directory] = @output_directory
      options[:input_directory] = @input_directory
      html = ToErb.new(options).render(template_html)
      "\n#{html}"
    end

    def span_class(file)
      classes = []
      classes << "error could_not_compile" if file[:error_file]
      classes << "optimized" if file[:is_a_compiled_file]
      classes << "error" if file[:error]

      classes << "include" if file[:include]
      classes << "include" if File.basename(file[:output_filename]).start_with? "_"

      classes << "cached" if file[:from_cache]

      extension = File.extname(file[:filename])[1..-1]
      classes << extension
      classes << 'image' if ['png', 'gif', 'svg', 'jpg', 'gif'].include? extension

      if extension == "html" || extension == "php"
        classes << "html"
      else
        # This isn't right! We may need a way of showing which files were compiled and which weren't.
        #TODO: Check whether the stylesheet references 'copied'
        # if file[:output_filename] == file[:filename]
          # classes << "copied"
        # else
          # classes << "success"
        # end
      end
      classes.uniq.join(" ")
    end

  end
end

### Body templates

# def error_template(error_object)
#   "<div class='build-error'>
#     <span>Error while building!</span>
#     <span>Error details:</span>
#     <p>#{error_object}</p>
#     <p>#{error_object && error_object.backtrace}</p>
#   </div>"
# end

# def not_found_template
#   "<div class='build-error not-found'><span>Folder not found</span></div>"
# end

# def no_files_template
#   "<div class='build-error no-files'><span>No files to build</span></div>"
# end