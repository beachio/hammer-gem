# encoding: utf-8
$LANG = "UTF-8"
require 'lib/hammer/templates/base'
require 'lib/hammer/templates/application/line'

module Hammer

  class HTMLTemplate < Template

    def line_for(file)
      Hammer::ApplicationTemplateLineTemplate.new(file, @output_directory)
    end

    def to_s
      return @text if @text
      application_template_path = File.join(File.dirname(__FILE__), "application", "application.html.erb")
      template_contents = File.new(application_template_path).read
      template = ERB.new(template_contents, nil, "%")
      @text = template.result(binding)
    end

    private

    def total_errors
      error_files.length rescue 0
    end

    def total_todos
      files.collect(&:messages).flatten.compact.length
    end

    ### Body templates

    def error_template(error_object)
      "
        <div class='build-error'>
          <span>Error while building!</span>
          <span>Error details:</span>
          <p>#{error_object}</p>
          <p>#{error_object && error_object.backtrace}</p>
        </div>
      "
    end

    def not_found_template
      "<div class='build-error not-found'><span>Folder not found</span></div>"
    end

    def no_files_template
      "<div class='build-error no-files'><span>No files to build</span></div>"
    end

    def html_includes
      files.select {|file| (['.php', '.html'].include? File.extname(file[:output_filename])) && !file[:error] && File.basename(file[:output_filename]).start_with?("_") }.compact
    end

    def todo_files
      files.select {|file|
        file[:messages].to_a.length > 0
      }
    end

    def error_files
      files.select {|file|
        file[:error]
      }.sort_by{|file|
        begin
          if file[:error] && file[:error][:hammer_file] != path
            100
          else
            10
          end
        rescue
          1000
        end
      }
    end

    def html_files
      files.select do |file|
        extension = File.extname(file[:output_filename])
        (['.php', '.html'].include? extension) && !file[:error]
      end.compact
    end

    def compilation_files
      files.select {|file|
        file[:is_a_compiled_file] # && file.source_files.collect(&:error) == []
        }.compact
    end

    def css_js_files
      files.select {|file|
        ['.css', '.js'].include?(File.extname(file[:output_filename])) && !file[:is_a_compiled_file] && !file[:error]
      }
    end

    def image_files
      files.select {|file| ['.png', '.gif', '.svg', '.jpg', '.gif'].include? File.extname(file[:output_filename]) }.compact
    end

    def other_files
      files - image_files - css_js_files - compilation_files - html_files - error_files
    end

    def ignored_files
      @project.ignored_files rescue []
    end

    def files_of_type(extension)
      files.select {|file| File.extname(file[:output_filename]) == extension}
    rescue
      []
    end

  end
end