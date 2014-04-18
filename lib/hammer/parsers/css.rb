require 'hammer/parser'
require 'bourbon'

module Hammer

  class CSSParser < Parser
    
    def to_format(format)
      if format == :css
        to_css
      else
        false
      end
    end
    
    def to_css
      @text || @hammer_file.raw_text
    end

    def parse(text)
      @text = text
      includes
      clever_paths
      url_paths
      import_url_paths
      return @text
    end
    
    register_as_default_for_extension :css
    accepts :css
    returns :css
    
  private
  
    def ignore_file_path?(file_path)
      file_path == "" || file_path[0..3] == "http" || file_path[0..1] == "//" || file_path[0..4] == "data:" || file_path[0..0] == "/"
    end
    
    def import_url_paths
      @text = replace(@text, /@import "(\S*?)"/) do |url_tag, line_number|
        
        file_path = url_tag.gsub('@import ', '').gsub('"', '').gsub(";", "").strip
        
        if ignore_file_path?(file_path)
          url_tag
        else
          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          file = find_file_with_dependency(file_name)
          
          if file
            url = path_to(file)
            "@import \"#{url}\";"
          else
            url_tag
          end
        end
      end
    end

    def url_paths
      @text = replace(@text, /url\((\S*?)\)/) do |url_tag, line_number|

        file_path = url_tag.gsub('"', '').gsub("url(", "").gsub(")", "").strip.gsub("'", "")
        
        if ignore_file_path?(file_path)
          url_tag
        else
          
          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          extras = file_path.split(file_name)[1]
          
          file = find_files(file_name)[0]

          if file
            url = path_to(file)
            "url(#{url}#{extras if extras})"
          else
            url_tag
          end
        end
      end
    end
    
    def clever_paths
      @text = replace(@text, /\/\* @path (.*?) \*\//) do |tag, line_number|
        
        file_path = tag.gsub('/* @path ', '').gsub("*/", "").strip
        
        if ignore_file_path?(file_path)
          tag
        else
          
          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          file = find_files(file_name)[0]
          
          file ? path_to(file) : tag
        end
      end
    end
    
    def includes
      lines = []
      @text = replace(@text, /\/\* @include (.*) \*\//) do |tag, line_number|
        return tag if tag.include? "("

        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          # add_wildcard_dependency tag
          file = find_file_with_dependency(tag, 'css')
          raise "Included file <b>#{tag}</b> couldn't be found." unless file
          @parser = Hammer::Parser.for_filename(file).last.new()
          @parser.parse(File.open(file).read)
          @parser.to_css()
        end
        a.compact.join("\n")
      end
    end
  end

  class SASSParser < CSSParser

    accepts :sass, :scss
    returns :css
    
    def format=(format)
      @format = format.to_sym
    end
    
    def format
      @path.split('.')[-1].to_sym
    end
    
    def text=(new_text)
      super
      @raw_text = new_text
    end
    
    def to_css
      parse(@original_text)
    end
    
    def to_format(new_format)
      if new_format == :css
        parse(@original_text)
      elsif new_format == format
        @original_text
      elsif format == :scss and new_format == :sass
        # warn "SCSS to SASS isn't done"
        false
      elsif format == :sass and new_format == :scss
        # warn "SASS to SCSS isn't done"
        false
      else
      end
    end

    def parse(text)
      @original_text = text
      @text = text

      raise "Error in #{@path}: Wrong format (#{format})" unless ([:scss, :sass].include?(format))
      
      semicolon = format == :scss ? ";\n" : "\n"
      @text = ["@import 'bourbon'", "@import 'bourbon-deprecated-upcoming'", @text].join(semicolon)
      
      includes()
      clever_paths()

      engine = Sass::Engine.new(@text, options)

      begin
        @text = engine.render()
        
        dependencies = engine.dependencies.map {|dependency| dependency.options[:filename]}
        dependencies.each do |path|
          next unless path.start_with? @input_directory
          relative_path = path[@input_directory.length..-1] if path.start_with? @input_directory
          # find_file adds a hard dependency for us :)
          find_file_with_dependency(relative_path)
        end

      rescue => e
        if e.respond_to?(:sass_filename) and e.sass_filename and e.sass_filename != self.filename # && @input_directory
          # TODO: Make this nicer.
          @error_file = e.sass_filename.gsub(@input_directory + "/", "")
          file = find_file_with_dependency(@error_file, ['css', 'scss', 'sass'])
          if file
            error e.message, e.sass_line, file
          else
            error "Error in #{@error_file}: #{e.message}", e.sass_line - 2
          end
        elsif e.respond_to?(:sass_line) && e.sass_line
          error e.message, e.sass_line - 2
        end
      end
      
      @text = @text[0..-2] if @text.end_with? "\n"

      @text
    end
    
    def self.finished_extension
      "css"
    end
    
    private
    
    def includes
      lines = []
      @text = replace(@text, /\/\* @include (.*) \*\//) do |tag, line_number|
        
        return tag if tag.include? "("
        
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        
        replacement = []
        tags.each do |tag|

          file = find_file_with_dependency(tag, 'scss')

          raise "Included file <strong>#{tag}</strong> couldn't be found." unless file

          # TODO: Make a for_filename single method for a file and a directory. Something to generate the path anyway.
          # Hammer::Parser.convert(directory, file, format)
          # At the very least, update everywhere we use .for_fileanme in parsers.
          
          parser = Hammer::Parser.for_filename(file).first
          parser = parser.new(:path => file.gsub(@directory, ""))
          parser.parse(File.open(file).read)
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

      paths = []

      if @input_directory
        paths << escape_glob(@input_directory)
        paths << File.join(escape_glob(@input_directory), "**/*")
      end
      
      if @path
        paths << File.dirname(escape_glob(@path))
      end

      # paths << File.join(File.dirname(__FILE__), "..", "..", "..", "vendor", "gems", "bourbon-*", "app", "assets", "stylesheets")
      paths << File.join(File.dirname(__FILE__), "..", "..", "..", "vendor", "production", "bundle", "ruby", "2.0.0", "bundler", "gems", "bourbon-*", "app", "assets", "stylesheets")

      paths.compact
    end
    
    def escape_glob(s)
      s.gsub(/[\\\{\}\[\]\*\?]/) { |x| "\\"+x }
    end


    def options
      cache_directory = @cache_directory rescue Dir.mktmpdir
      {
        :disable_warnings => true,
        :syntax => format, 
        :load_paths => load_paths,
        :relative_assets => true,
        :quiet => true,
        # :source_encoding => Encoding::UTF_16, # This didn't work
        # :debug_info => !@production,
        :cache_location => @cache_directory,
        :sass => sass_options
      }
    end
    
    def sass_options
      { :quiet => true, :logger => nil }
    end
  end
end