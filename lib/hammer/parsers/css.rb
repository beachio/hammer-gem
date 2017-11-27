require 'hammer/parser'
require 'bourbon'
require 'neat'
require 'autoprefixer-rails'

module Hammer

  class CSSParser < Parser

    def to_format(format)
      if format == :css
        parse(@text)
      else
        false
      end
    end

    def parse(text, filename=nil,test=nil)
      @text = text

      text = includes(text)
      text = clever_paths(text)
      text = url_paths(text)
      text = import_url_paths(text)

      return text unless Settings.autoprefixer
      autoprefixer_process(text, (!optimized && Settings.sourcemaps))
    end

    register_as_default_for_extension :css
    accepts :css
    returns :css

  private

    def ignore_file_path?(file_path)
      return true if file_path.split("")[0] == "#"
      return true if file_path == ""
      return true if file_path[0..3] == "http"
      return true if file_path[0..1] == "//"
      return true if file_path[0..4] == "data:"
      return true if file_path[0..0] == "/"
    end

    def import_url_paths(text)
      replace(text, /@import "(\S*?)"/) do |url_tag, line_number|

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

    def url_paths(text)
      replace(text, /url\((\S*?)\)/) do |url_tag, line_number|
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

    def clever_paths(text)
      replace(text, /\/\* @path (.*?) \*\//) do |tag, line_number|

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

    def includes(text)
      lines = []
      replace(text, /\/\* @include (.*) \*\//) do |tag, line_number|
        return tag if tag.include? "("

        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          # TODO!
          # add_wildcard_dependency tag
          file = find_file_with_dependency(tag, 'css')
          raise "Included file <b>#{tag}</b> couldn't be found." unless file
          parse_file(file, :css)
        end
        a.compact.join("\n")
      end
    end

    def autoprefixer_process(text, sourcemap = false)
      result_filename = filename.gsub(/[^\.]+$/, 'css')
      if sourcemap
        sass_map_path = "#{output_directory}/#{result_filename}.map"
        map_options = { inline: false }
        if File.exist?(sass_map_path)
          map_options.merge!(prev: File.read(sass_map_path))
        end
      else
        map_options = false
      end

      result = AutoprefixerRails.process(
        text,
        Settings.autoprefixer.merge(
          map: map_options,
          from: filename,
          to: result_filename
        )
      )
      
      File.open(sass_map_path, 'w') { |f| f.write(result.map) } if sourcemap
      result.css
    end
  end
end
