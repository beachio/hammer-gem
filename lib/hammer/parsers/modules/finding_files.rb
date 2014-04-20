module Hammer
  module FindingFiles

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
        extension = extension.to_s
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

    def find_file(*args)
      find_files(*args)[0]
    end

    def self.included(base)
      # Dependency tree alert!
      # TODO: Figure out a way to bring FindingFiles and Extensions closer together, if possible.
      base.send :include, Hammer::Extensions
    end

  private

    # Get all the filenames for the current build. 
    # This involves @directory if we have one, or @filenames if we don't.
    def filenames

      # This checks for it being an array and not nil!
      return @filenames unless @filenames.empty?

      # This means we can add files to the output 
      if @directory
        @filenames = Dir.glob(File.join(@directory, "**/*")).map {|file|
          file.gsub(@directory+"/", "")
        }
      else
        @filenames = []
      end

      @filenames

    end

    def absolute_to_relative(filename)
      filename = filename[1..-1] if filename.start_with? "/"
      filename
    end
  end
end