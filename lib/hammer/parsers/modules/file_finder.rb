module Hammer
  module FileFinder

    attr_accessor :filenames

    def filenames
      if @filenames.any?
        @filenames
      else
        Dir.glob(File.join(@directory, "**/*")).map {|file|
          file.gsub(@directory+"/", "")
        }
      end
    end

    def regex_for(filename, extension=nil)
      
      require "uri"
      filename = URI.parse(filename).path
      
      extensions = [*extension].compact
      if !extension
        extension =  File.extname(filename)[1..-1]
        # filename = File.basename(filename, ".*")
        if extension
          filename = filename[0..-extension.length-2]
        end
      end

      extensions = extensions + possible_other_extensions_for_extension(extension)
      extensions = extensions.flatten
      
      extensions.each do |extension|
        # If they're finding (index.html, html) we need to remove the .html from the tag.
        if extension && filename[-extension.length-1..-1] == ".#{extension}" 
          filename = filename[0..-extension.length-2]
        end
      end
      
      # /index.html becomes ^index.html  
      filename = filename.split("")[1..-1].join("") if filename.start_with? "/"

      filename = Regexp.escape(filename).gsub('\*','.*?')
      if extensions != []
        /(^|\/|_)#{filename}\.(#{extensions.join("|")})/
      elsif extension
        /(^|\/|_)#{filename}.#{extension}/
      else
        /(^|\/|_)#{filename}/
      end
    end

    def find_files(query, extension=nil)

      # TODO: Cache this method

      query = absolute_to_relative(query)
      regex = regex_for(query, extension)

      matches = filenames.to_a.select { |filename|
        match = filename =~ regex

        # straight_basename = false  # File.basename(file.filename) == filename
        # no_extension_required = extension.nil?
        # has_extension = File.extname(file.filename) != ""

        (File.extname(filename) != "" || extension.nil?) && (match)
      }.sort_by {|filename|
        filename.to_s
      }.sort_by { |filename|

        basename      = File.basename(filename)
        match         = basename == [filename, extension].compact.join(".")
        partial_match = basename == ["_"+filename, extension].compact.join(".")

        score = filename.split(query).join.length

        if match
          score
        elsif partial_match
          score + 10
        else
          score + 100
        end

      }

      # If we query with a *, return all results. Otherwise, first result only.
      matches = matches[0..0] unless query.include?('*')

      return matches
    end

    def self.included(base)
      # Dependency tree alert!
      # TODO: Figure out a way to bring FileFinder and ExtensionMapper closer together, if possible.
      base.send :include, Hammer::ExtensionMapper
    end

  private

    def absolute_to_relative(filename)
      filename = filename[1..-1] if filename.start_with? "/"
      filename
    end
  end
end