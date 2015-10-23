module Hammer
  module FindingFiles

    def regex_for(filename, extension=nil)

      require "uri"
      filename = URI.parse(filename).path

      extensions = [*extension].compact
      extensions = extensions.map {|e| e.to_sym}

      if !extension
        extension =  File.extname(filename)[1..-1]
        # filename = File.basename(filename, ".*")
        if extension
          filename = filename[0..-extension.length-2]
        end
      end

      if extension
        extensions = extensions + possible_other_extensions_for_extension(extension)
        extensions = extensions.flatten
      end

      extensions.each do |extension|
        extension = extension.to_s
        # If they're finding (index.html, html) we need to remove the .html from the tag.
        if extension && filename[-extension.length-1..-1] == ".#{extension}"
          filename = filename[0..-extension.length-2]
        end
      end
      extensions = extensions.compact.uniq

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

    # TODO: Pass filenames into find_files
    def find_files(query, extension=nil)
      search_key = "#{query}.#{extension}"
      $cached_findings ||= Hash.new([])
      if $cached_findings[search_key].size > 0
        return $cached_findings[search_key]
      end
    
      # TODO: Cache this method
      query = absolute_to_relative(query)
      query = query.gsub("../", "")
      regex = regex_for(query, extension)

      matches = all_filenames.to_a.select { |filename|
        match = filename =~ regex
        (File.extname(filename) != "" || extension.nil?) && (match)
      }.sort_by {|filename|
        filename.to_s
      }.sort_by { |filename|

        basename      = File.basename(filename)
        match         = basename == [filename, extension].compact.join(".")
        partial_match = basename == ["_"+query, extension].compact.join(".")

        score = filename.split(query).join.length

        if match
          score
        elsif partial_match
          score + 10
        else
          score + 100
        end

      }
      $cached_findings[search_key] = matches
      # If we query with a *, return all results. Otherwise, first result only.
      query.include?('*') ? $cached_findings[search_key] : $cached_findings[search_key][0..0]
    end

    def find_file(*args)
      find_files(*args)[0] || ContentProxy.find_file(args.first)
    end

    def self.included(base)
      # Dependency tree alert!
      # TODO: Figure out a way to bring FindingFiles and Extensions closer together, if possible.
      base.send :include, Hammer::Extensions
    end


    # Get all the filenames for the current build.
    # This involves @directory if we have one, or @filenames if we don't.
    def all_filenames


      # This checks for it being an array and not nil!
      # return @filenames if @filenames && !@filenames.empty?

      # This means we can add files to the output
      return $filenames if $filenames && $filenames.size > 5 # I guess that small numbers are errors too
      
      if @directory
        $filenames = Dir.glob(File.join(@directory, "**/*")).map {|file|
          next if @output_directory && file.start_with?("@output_directory/")
          file.gsub(@directory+"/", "")
        }.compact
      else
        []
      end
    end

    def absolute_to_relative(filename)
      filename = filename[1..-1] if filename.start_with? "/"
      filename
    end
  end
end