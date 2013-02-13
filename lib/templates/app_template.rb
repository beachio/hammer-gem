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
      [header, body].join("\n")
    end
    
    def header
      "10 files compiled"
    end
    
    def body
      
      body = []
      
      html_files = files_of_type('.html')
      if html_files.any?
        body << "<h3>HTML files</h3>"
        html_files.each do |file|
          body << line_for_file(file)
        end
      end
      
      assets = files - html_files
      
      if assets.any?
        body << "<h3>Assets</h3>"
        assets.each do |file|
          body << line_for_file(file)
        end
      end
      
      body.join("\n")
    end
    
    def line_for_file(file)
      TemplateLine.new(file).to_s
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
      
      def initialize(file)
        @file = file
        @error = file.error
        @error_message = file.error_message
        @error_line = file.error_line
        @error_file = file.error_file
        @filename = file.finished_filename
        @messages = file.messages
      end
      
      def messages
        @messages.map {|message|
          %Q{
            <span class="error message">
              #{h message[:message]}
            </span>
          }
        }.join("")
      end
      
      def span_class
        "compiled"
      end
            
      def input_path
        @file.full_path
      end
      
      def output_path
        @file.full_path
      end
      
      def filename
        @file.filename
      end
      
      def link
        %Q{
          <a target="_blank" href="#{h output_path} title="#{h input_path}">#{filename}</a>
        }
      end
      
      def line
        if error
          line = %Q{
            Error in #{link} on line #{error_line}: #{error_message}
          }
        elsif error_file
          puts "a"
          line = %Q{
            Couldn't compile #{link} due to an error in #{error_file}: #{related_file_error_message}
          }
        else
          "Compiled #{link}"
        end
      end
      
      def to_s
        %Q{
          <div class="file #{span_class}">
            <span class="#{span_class}">#{line}</span>
            #{messages}
          </div>
        }
      end
    end
    
  end
end