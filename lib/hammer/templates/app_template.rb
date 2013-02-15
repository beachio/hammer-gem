module Templatey
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

class Hammer
  
  class Template
    def initialize(files)
      @files = files
    end
    
    def success?
      @files != nil and @files.length > 0 and @files.select {|file| file.error} == []
    end
    
    def to_s; raise "No such method"; end
  end
  
  class AppTemplate < Template
    
    def to_s
      [header, stylesheet, body].join("\n")
    end
    
    private
    
    def stylesheet
      css = File.open(File.join(File.dirname(__FILE__), "output.css")).read
      %Q{<style type="text/css">#{css}</style>}
    end
    
    def header
      
      line = []
      
      ['html', 'js', 'css'].each do |extension|
        files = files_of_type(".#{extension}").length
        if files > 0
          line << "#{files} #{extension.upcase} file#{"s" if files != 1}"
        end
      end
      
      line.join(", ")
    end
    
    def not_found
      "<div class='build-error not-found'><span>Folder not found</span></div>"
    end
    
    def no_files
      "<div class='build-error no-files'><span>No files to build</span></div>"
    end
    
    def body
      
      return not_found if @files == nil
      return no_files if @files == []
      
      body = []
      files = sorted_files
      
      error_files = files.select {|file| file.error }
      error_files = error_files.sort_by{|file|
        if file.error.hammer_file != file
          100
        else
          10
        end
      }
      
      if error_files.any?
        body << "<h3>Errors</h3>"
        body << error_files.map {|file| TemplateLine.new(file)}
      end
      
      files = files - [*error_files]
      
      html_files = files.select {|file| File.extname(file.finished_filename) == ".html" && !File.basename(file.finished_filename).start_with?("_") }.compact
      
      if html_files.any?
        body << "<h3>HTML files</h3>"
        body << html_files.map {|file| TemplateLine.new(file)}
      end

      assets = files - html_files
      
      if assets.any?
        body << "<h3>Assets</h3>"
        body << assets.map {|file| TemplateLine.new(file)}
      end
      
      body.join("\n")
    end
    
    def files_of_type(extension)
      sorted_files.select {|file| File.extname(file.finished_filename) == extension}
    rescue
      []
    end
    
    def sorted_files
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
        @extension = File.extname(@file.finished_filename)[1..-1]
        @include = File.basename(file.filename).start_with?("_")
      end
      
      def messages
        @messages.map {|message|
          %Q{<span class="error message">#{message[:message]}</span>}
        }.join("")
      end
      
      def span_class
        return "could_not_compile" if @error_file
        
        classes = []
        
        classes << "error" if @error
        classes << "include" if @include

        if @extension == "html"
          classes << "html"          
        else
          classes << "success" if @file.compiled
          classes << "copied"
        end
        
        classes.join(" ")
      end
            
      def link
        %Q{<a target="_blank" href="#{h output_path}" title="#{h input_path}">#{filename}</a>}
      end
      
      def line
        if @error_file
          "Couldn't compile #{link} due to an error in #{@error_file.filename}"
        elsif @error
          "Error in #{link} on <strong>line #{error_line}</strong>:
          <span class=\"error message\">#{error_message}</span>"
        elsif !@file.compiled
          "Copied #{link}"
        elsif @extension == "html"
          "Built #{link}"
        else
          "Compiled #{link}"
        end
      end
      
      def to_s
        if @include && !@error
          return ""
        else
          %Q{<span class="file #{extension} #{span_class}">#{line}</span>#{messages}}
        end
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
        @file.filename
      end
    end
    
  end
end