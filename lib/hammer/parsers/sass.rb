require 'hammer/parser'
require 'hammer/parsers/css'
require 'hammer/parsers/sass'
require 'bourbon'
require 'fileutils'

module Hammer
  class SASSParser < CSSParser

    accepts :sass, :scss
    returns :css

    def format
      @path.split('.')[-1].to_sym
    end

    def to_format(new_format)
      if new_format == :css
        parse(@original_text)
      elsif new_format == format
        @original_text
      elsif format == :scss and new_format == :sass
        # warn "SCSS to SASS isn't done"
        false
      # elsif format == :sass and new_format == :scss
      #   # warn "SASS to SCSS isn't done"
      #   false
      end
    end

    def parse(text, filename=nil)
      @filename = filename
      @original_text = text
      @text = text

      raise "Error in #{@path}: Wrong format (#{format})" unless ([:scss, :sass].include?(format))

      semicolon = format == :scss ? ";\n" : "\n"
      text = ["@import 'bourbon'", text].join(semicolon)

      text = includes(text)
      text = clever_paths(text)

      begin
        engine = Sass::Engine.new(text, options)
        text = if !optimized && @filename && Settings.sourcemaps
                 render_with_sourcemap(engine)
               else
                 engine.render
               end

        dependencies = engine.dependencies.map {|dependency| dependency.options[:filename]}
        dependencies.each do |path|
          relative_path = path
          if @input_directory
            # skip all these Bourbon and Bourbon accessories
            next unless path.start_with? @input_directory
            # Add a file dependency for each SASS dependency!
            relative_path = path[@input_directory.length..-1] if path.start_with? @input_directory
            relative_path = relative_path[1..-1] if relative_path.start_with?("/")
          end
          add_dependency(relative_path)
        end

      rescue => e
        # Something's gone wrong. This is most likely to be a SASS error.
        # TODO: Rescue only a certain kind of error here and use finally/ensure!

        message = e.message
        # message = message.split("Load paths:\n")[0] if message.include? 'Load paths:'
        @error_line = e.sass_line if e.respond_to?(:sass_line)

        if e.respond_to?(:sass_filename) and e.sass_filename and e.sass_filename != self.filename # && @input_directory
          @error_file = e.sass_filename.gsub(@input_directory + "/", "")
          file = find_file_with_dependency(@error_file, ['css', 'scss', 'sass'])
          raise "Error in #{@error_file}: #{e.message}" unless file
          @error_file = file
          raise message
        elsif e.respond_to?(:sass_line) && e.sass_line
          # The error is in this file, so we'd better take off the two lines for Bourbon.
          @error_line -= 1
        end
        raise message
      end

      text = text[0..-2] if text.end_with? "\n"
      text
    end

  private

    def includes(text)
      lines = []
      replace(text, /\/\* @include (.*) \*\//) do |tag, line_number|

        return tag if tag.include? "("

        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")

        replacement = []
        tags.each do |tag|

          file = find_file_with_dependency(tag, 'scss')

          raise "Included file <strong>#{tag}</strong> couldn't be found." unless file

          parser = Hammer::Parser.for_filename(file).first
          parser = parser.new(:path => file.gsub(@directory, ""))
          parser.optimized        = optimized
          parser.parse(read(file))
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

      if @input_directory && @path
        paths << File.dirname(escape_glob(File.join(@input_directory, @path)))
      end

      # paths << File.join(File.dirname(__FILE__), "..", "..", "..", "vendor", "gems", "bourbon-*", "app", "assets", "stylesheets")
      # paths << File.join(File.dirname(__FILE__), "..", "..", "..", "vendor", "production", "bundle", "ruby", "2.0.0", "gems", "bourbon-*", "app", "assets", "stylesheets")
      # paths << File.join(File.dirname(__FILE__), "..", "..", "..", "vendor", "production", "bundle", "ruby", "2.0.0", "gems", "neat-*", "app", "assets", "stylesheets")

      paths.compact
    end

    def escape_glob(s)
      s.gsub(/[\\\{\}\[\]\*\?]/) { |x| "\\"+x }
    end

    def render_with_sourcemap(engine)
      map_filename = @filename.gsub(/[^\.]+$/, '') + 'css.map'
      map_filepath = @output_directory + '/' + map_filename

      text, map = engine.render_with_sourcemap(File.basename(map_filename))

      map_dir = File.dirname(map_filepath)
      FileUtils.mkdir_p(map_dir) unless File.directory?(map_dir)

      File.open(map_filepath, 'w') do |f| 
        f.write map.to_json(
          css_path: File.expand_path(@filename),
          sourcemap_path: map_filename,
          type: :inline
        ).gsub(@input_directory, '')
      end
      text
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
        :filename => "#{input_directory}/#{@filename}",
        :cache_location => @cache_directory,
        :sass => sass_options
      }
    end

    def sass_options
      { :quiet => true, :logger => nil }
    end
  end
end