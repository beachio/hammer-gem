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
    
    def to_s; raise "No such method"; end
  end
  
  class AppTemplate < Template

    def to_s
      [header, stylesheet, body].join("\n")
    end
    
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
    
    def body
      
      body = []
      
      html_files = files_of_type('.html')

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
      files.select {|file| File.extname(file.finished_filename) == extension}
    end
    
    def files
      
      # This sorts the files into the correct order for display
      @files.sort_by { |file|
        extension = File.extname(file.finished_filename).downcase
        length = file.finished_filename.length

        if file.error # (file.result == :error) || file.error != nil
          0 + length
        elsif file.error
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
        @error_message = file.error_message
        @error_line = file.error_line
        @error_file = file.error_file
        @filename = file.finished_filename
        @messages = file.messages
        @extension = File.extname(@file.finished_filename)[1..-1]
        @include = File.basename(file.filename).split("")[0] == "_"
      end
      
      def messages
        @messages.map {|message|
          %Q{<span class="error message">#{h message[:message]}</span>}
        }.join("")
      end
      
      def span_class
        return "could_not_compile" if @error_file
        
        classes = []
        
        classes << "error" if @file.error
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
        if @include && !@error
          ""
        elsif @error
          "Error in #{link} on line #{error_line}: #{error_message}"
        elsif @error_file
          "Couldn't compile #{link} due to an error in #{error_file}: #{related_file_error_message}"
        elsif !@file.compiled
          "Copied #{link}"
        elsif @extension == "html"
          "Built #{link}"
        else
          "Compiled #{link}"
        end
      end
      
      def to_s
        %Q{<span class="file #{extension} #{span_class}">#{line}</span>#{messages}}
      end
      
      private
      
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