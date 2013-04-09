
# encoding: utf-8
$LANG = "UTF-8"

module Templatey
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

class Hammer
  
  class Template
    def initialize(files, project)
      @files = files
      @project = project
    end
    
    def success?
      @files != nil and @files.length > 0 and @files.select {|file| file.error} == []
    end
    
    def to_s; raise "No such method"; end
  end
  
  class AppTemplate < Template
    
    def to_s
      if @files == nil
        return [header, not_found, footer].join("\n")
      elsif @files == []
        [header, no_files, footer].join("\n")
      else
        [header, nav, body, footer].join("\n")
      end
    end
    
    private
    
    def output_css
      File.open(File.join(File.dirname(__FILE__), "../../../assets/output.css")).read
    end
    
    def jquery
      File.open(File.join(File.dirname(__FILE__), "../../../assets/jquery.min.js")).read
    end
    
    def tabs
      File.open(File.join(File.dirname(__FILE__), "../../../assets/tabs.js")).read
    end
    
    def header
      %Q{
        <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
          <link href="output.css" rel="stylesheet" />
          <script src="jquery.min.js" type="text/javascript"></script>
          <script src="tabs.js" type="text/javascript"></script>
        </head>
        <body>
      }
    end
    
    def nav
      
      %Q{
          <header>
            <nav>
              <ul>
                <li id="show-all" class="active">All</li>
                <li id="show-html">HTML</li>
                <li id="show-cssjs">CSS &amp; JS</li>
                #{%Q{<li id="show-images">Images</li>} if image_files.length > 0}
                #{%Q{<li id="show-other">Other</li>} if other_files.length > 0}
              </ul>
              <ul>
                #{%Q{
                  <li id="show-todos">#{total_todos} Todo#{"s" if total_todos != 1}</li>
                } if total_todos > 0}
                
                #{%Q{
                    <li id="show-error">#{total_errors} Error#{"s" if total_errors != 1}</li>
                } if total_errors > 0}
                
                #{%Q{<li id="show-ignored">Ignored Files</li>} if ignored_files.length > 0}
              </ul>
            </nav>
          </header>
      }
    end
    
    def total_errors
      error_files.length rescue 0
    end
    
    def total_todos
      sorted_files.collect(&:messages).flatten.compact.length
    end
    
    def footer
      %Q{</body></html>}
    end
    
    def not_found
      "<div class='build-error not-found'><span>Folder not found</span></div>"
    end
    
    def no_files
      "<div class='build-error no-files'><span>No files to build</span></div>"
    end
    
    def todo_files
      sorted_files.select {|file| 
        file.messages.length > 0
      }
    end
    
    def error_files
      sorted_files.select {|file| 
        file.error 
      }.sort_by{|file|
        if file.error.hammer_file != file 
          100
        else
          10
        end
      }
    end
    
    def ignored_files
      sorted_files.select {|file| file.is}
    end
    
    def html_files
      sorted_files.select {|file| File.extname(file.finished_filename) == ".html" && !file.error }.compact
    end
    
    def compilation_files
      sorted_files.select {|file| 
        file.is_a_compiled_file # && file.source_files.collect(&:error) == [] 
        }.compact
    end
    
    def css_js_files
      sorted_files.select {|file| 
        ['.css', '.js'].include?(File.extname(file.finished_filename)) && !file.is_a_compiled_file && !file.error
      }
    end
    
    def image_files
      sorted_files.select {|file| ['.png', '.gif', '.svg', '.jpg', '.gif'].include? File.extname(file.finished_filename) }.compact
    end
    
    def other_files
      sorted_files - image_files - css_js_files - compilation_files - html_files - error_files
    end
    
    def ignored_files
      @project.ignored_files rescue []
    end
    
    def body
      
      return not_found if @files == nil
      return no_files if @files == []
      
      body = [%Q{<section id="all">}]
      files = sorted_files
      
      # if error_files.any?
        body << %Q{<div class="error set">}
        body << "<strong>Errors</strong>"
        body << error_files.map {|file| TemplateLine.new(file) }
        body << %Q{</div>}
      # end
      
      # if html_files.any?
        body << %Q{<div class="html set">}
        body << "<strong>HTML pages</strong>"
        body << html_files.map {|file| TemplateLine.new(file) if !file.error }
        body << %Q{</div>}
      # end
      
      # if compilation_files.any?
        body << %Q{<div class="optimized cssjs set">}
        body << %Q{ <strong>Optimized CSS &amp; JS</strong> }
        body << compilation_files.map {|file| TemplateLine.new(file) if !file.error }
        body << %Q{</div>}
      # end
      
      # if css_js_files.any?
        body << %Q{<div class="cssjs set">}
        body << "<strong>CSS &amp; JS</strong>"
        body << css_js_files.map {|file| TemplateLine.new(file) if !file.error }
        body << %Q{</div>}
      # end
      
      # if image_files.any?
        body << %Q{<div class="images set">}
        body << %Q{<strong>Image assets</strong>}
        body << image_files.map {|file| TemplateLine.new(file)}
        body << %Q{</div>}
      # end
      
      # if other_files.any?
        body << %Q{<div class="other set">}
        body << %Q{<strong>Other files</strong>}
        body << other_files.map {|file| TemplateLine.new(file)}
        body << %Q{</div>}
      # end
      
      # if ignored_files.any?
        body << %Q{<div class="ignored set">}
        body << %Q{<strong>Ignored files</strong>}
        body << ignored_files.map {|file| IgnoredTemplateLine.new(file)}
        body << %Q{</div>}
      # end
      
      body << %Q{</section>}
      
      # if todo_files.any?
        body << %Q{<section id="todos">
          <strong>Todos</strong>
          <div class="todos set"></div>
        </section>}
      # end
            
      body.join("\n")
    end
    
    def files_of_type(extension)
      sorted_files.select {|file| File.extname(file.finished_filename) == extension}
    rescue
      []
    end
    
    def sorted_files
      return [] if @files.nil?
      # This sorts the files into the correct order for display
      @sorted_files ||= @files.sort_by { |file|
        extension = File.extname(file.finished_filename).downcase
        length = file.finished_filename.length

        if file.error # (file.result == :error) || file.error != nil
          0 + length
        elsif file.filename == "index.html"
          1000 + length
        elsif extension == ".html"
          10000 + length
        elsif extension == ".css" || extension == ".sass" || extension == ".scss"
          100000 + length
        elsif extension == ".js" || extension == ".coffee"
          200000 + length
        else
          1000000 + length
        end
      }.select { |file|
        underscore = File.basename(file.finished_filename).start_with? "_"
        !underscore || file.messages.count > 0 || file.error
      }
    end

    class TemplateLine
      
      include Templatey
      
      attr_reader :error, :error_file, :related_file_error_message, :error_message, :error_line
      attr_reader :extension
      
      def initialize(file)
        @file = file
        
        @error = file.error
        
        if file.error
          @error_message = file.error.text
          @error_line = file.error.line_number
          if file.error.hammer_file != @file
            @error_file = file.error.hammer_file
          end
        end
        
        @filename = file.finished_filename
        @messages = file.messages
        @extension = File.extname(@file.filename)[1..-1]
        @include = File.basename(file.filename).start_with?("_")
      end
      
      def span_class
        
        classes = []
        
        classes << "error could_not_compile" if @error_file
        classes << "optimized" if @file.is_a_compiled_file
        classes << "error" if @error
        classes << "include" if @include
        
        classes << @extension
        if ['png', 'gif', 'svg', 'jpg', 'gif'].include? @extension
          classes << 'image'
        end
        
        if @extension == "html"
          classes << "html"          
        else
          classes << "success" if @file.compiled
          classes << "copied"
        end
        
        classes.join(" ")
      end
            
      def link
        %Q{<a target="_blank" href="#{h output_path}">#{@file.finished_filename}</a>}
      end
      
      def setup_line
        if @error_file
          @line = "Error in #{@error_file.filename}"
        elsif @error
          lines = ["<span class=\"error\">"]
          lines << "<b>Line #{error_line}:</b> " if error_line
          lines << error_message
          lines << "</span>"
          @line = lines.join()
        elsif @include
          @line = "Compiled to <b>#{link}</b>"
        elsif !@file.compiled
          # @line = "Copied to <b>#{link}</b>"
        elsif @extension == "html"
          @line = "Compiled to <b>#{link}</b>"
        elsif @file.is_a_compiled_file
          sources = @file.source_files.map { |hammer_file| "<a href='#{@file.output_path}' title='#{hammer_file.full_path}'>#{File.basename(hammer_file.filename)}</a>" }
          @line = "Compiled into #{link}"
        else
          @line = "Compiled to #{link}"
        end
      end
      
      def line
        @line || setup_line
        @line
      end
      
      def links
        links = [
          %Q{<a target="blank" href="reveal://#{@file.output_path}" class="reveal" title="Reveal Built File">Reveal in Finder</a>}
        ]
        if @filename.end_with?(".html") && @file.output_path
          links.unshift %Q{<a target="blank" href="#{@file.output_path}" class="browser" title="Open in Browser">Open in Browser</a>}
        end
        if ['.html', ".css", ".js"].include?(File.extname(@filename))
          links.unshift %Q{<a target="blank" href="edit://#{@file.full_path}" class="edit" title="Edit Original">Edit Original</a>}
        end
        links
      end
      
      def todos
        @file.messages.map do |message|
          %Q{
            <span class="#{message[:html_class] || 'error'}">
              #{"<b>Line #{message[:line]}</b>" if message[:line]} 
              #{message[:message]}
            </span>
          }
        end
      end
      
      def to_s
        text = %Q{
          <article class="#{span_class}" hammer-original-filename="#{@file.full_path}" hammer-final-filename="#{@file.output_path}">
            <span class="filename">#{filename}</span>
            <small class="#{span_class}">#{line}</small>
            #{todos}
            #{links}
          </article>
        }
      end
      
      private
      
      def error_file
        
      end
      
      def input_path
        @file.full_path
      end
      
      def output_path
        @file.output_path
      end
      
      def filename
        if @file.is_a_compiled_file
          @file.source_files.collect(&:filename).join(', ')
        else
          @file.filename
        end
      end
    end
    
    class IgnoredTemplateLine < TemplateLine
      def to_s
        %Q{<article class="ignored #{span_class}">
          <span class="filename">#{filename}</span>
        </article>}
      end
    end
    
  end
end