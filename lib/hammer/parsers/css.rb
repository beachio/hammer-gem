class Hammer

  class CSSParser < HammerParser
    
    def to_format(format)
      if format == :css
        to_css
      end
    end
    
    def format
      filename.split('.')[-1].to_sym
    end
    
    def to_css
      @hammer_file.raw_text
    end

    def parse
      includes
      clever_paths
      url_paths
      return @text
    end
    
    def self.finished_extension
      "css"
    end
    
  private

    def url_paths
      replace(/url\((\S*?)\)/) do |url_tag, line_number|

        file_path = url_tag.gsub('"', '').gsub("url(", "").gsub(")", "").strip.gsub("'", "")
        
        if file_path == "" || file_path[0..3] == "http" || file_path[0..1] == "//" || file_path[0..4] == "data:"
          url_tag
        else
          
          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          extras = file_path.split(file_name)[1]
          file = find_file(file_name)
          
          if file
            url = Pathname.new(file.output_filename).relative_path_from Pathname.new(File.dirname(filename))
            "url(#{url}#{extras if extras})"
          else
            url_tag
          end
        end
      end
    end
    
    def includes
      lines = []
      replace(/\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          add_wildcard_dependency tag
          file = find_file(tag, 'css')
          raise "Included file <b>#{tag}</b> couldn't be found." unless file
          Hammer.parser_for_hammer_file(file).to_css()
        end
        a.compact.join("\n")
      end
    end

    def clever_paths
    end
  end
  register_parser_for_extensions CSSParser, ['css']
  register_parser_as_default_for_extensions CSSParser, ['css']

  class SASSParser < HammerParser
    
    def format=(format)
      @format = format.to_sym
    end
    
    def format
      filename.split('.')[-1].to_sym
    end
    
    def text=(new_text)
      super
      @raw_text = new_text
    end
    
    def to_css
      parse
    end
    
    def to_format(new_format)
      if new_format == :css
        parse
      elsif new_format == format
        @raw_text
      elsif format == :scss and new_format == :sass
        # warn "SCSS to SASS isn't done"
        false
      elsif format == :sass and new_format == :scss
        # warn "SASS to SCSS isn't done"
        false
      else
      end
    end

    def parse
      
      if !([:scss, :sass].include?(format))
        raise "Error in #{@hammer_file.filename}: Wrong format (#{format})"
      end
      
      semicolon = format == :scss ? ";\n" : "\n"
      @text = ["@import 'bourbon'", "@import 'bourbon-deprecated-upcoming'", @text].join(semicolon)
      
      includes()
      
      engine = Sass::Engine.new(@text, options)
      begin
        @text = engine.render()
        
        engine.dependencies.each do |dependency|
          
          path = dependency.options[:filename]
          next unless path.start_with? @hammer_project.input_directory
          
          if path.start_with? @hammer_project.input_directory
            relative_path = path[@hammer_project.input_directory.length..-1]
          end
          
          # find_file adds a hard dependency for us :)
          find_file(relative_path)
        end
        
      rescue => e
        if e.respond_to?(:sass_filename) and e.sass_filename and e.sass_filename != self.filename
          # TODO: Make this nicer.
          @error_file = e.sass_filename.gsub(@hammer_project.input_directory + "/", "")
          file = @hammer_project.find_file(@error_file, ['css', 'scss', 'sass'])
          if file
            error e.message, e.sass_line, file
          else
            error "Error in #{@error_file}: #{e.message}", e.sass_line - 2
          end
        else
          if e.respond_to?(:sass_line) && e.sass_line
            error e.message, e.sass_line - 2
          end
        end
      end
      @text
    end
    
    def self.finished_extension
      "css"
    end
    
    private
    
    def includes
      lines = []
      replace(/\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        
        replacement = []
        tags.each do |tag|
          
          file = find_file(tag, 'scss')
          
          raise "Included file <strong>#{tag}</strong> couldn't be found." unless file
          
          parser = Hammer.parser_for_hammer_file(file)
          text = parser.to_format(format)
          
          if !text
            # Go back to CSS.
            replacement << "/* @include #{tag} */"
          elsif text
            # to_format has taken care of us!
            replacement << text
          end
        end
        replacement.compact.join("\n")
      end
    end
    
    def load_paths
      if @hammer_file.full_path && @hammer_project.input_directory
        [
          File.dirname(escape_glob(@hammer_file.full_path)),
          File.join(escape_glob(@hammer_project.input_directory), "**/*"),
          File.join(File.dirname(__FILE__), "../../../vendor/gems/bourbon-*/app/assets/stylesheets")
        ].compact
      else
        [
          File.join(File.dirname(__FILE__), "../../../vendor/gems/bourbon-*/app/assets/stylesheets")
        ].compact
      end
    end
    
    def escape_glob(s)
      s.gsub(/[\\\{\}\[\]\*\?]/) { |x| "\\"+x }
    end


    def options
      {
        :disable_warnings => true,
        :syntax => format, 
        :load_paths => load_paths,
        :relative_assets => true,
        # :debug_info => !@hammer_project.production,
        # :cache_location => @hammer_project.sass_cache_directory,
        :sass => sass_options
      }
    end
    
    def sass_options
      { :quiet => true, :logger => nil }
    end
  end
  register_parser_for_extensions SASSParser, ['sass', 'scss', 'css']
  register_parser_as_default_for_extensions SASSParser, ['sass', 'scss']
end