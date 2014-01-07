require 'hammer/parser'

module Hammer
  class Utils
  
    def self.output_filename_for(filename)
      extension = File.extname(filename)[1..-1]
      parser = Hammer::Parser.for_extension(extension).last

      if parser
        path      = File.dirname(filename)
        basename  = File.basename(filename, ".*")
        extension = parser.finished_extension

        Pathname.new("#{path}/#{basename}.#{extension}").cleanpath.to_s
      else
        filename
      end
    end

    # Fetches ["css"] for "scss" and ["js"] for "coffee"
    def self.possible_other_extensions_for_extension(extension)
      extensions = []
      parsers = Hammer::Parser.for_extension(extension)
      parsers.each do |parser|
        Hammer::Parser.extensions_for(parser).each do |extension|
          extensions << extension
        end
      end

      extensions = Hammer::Parser.all.select {|parser|
        parser.finished_extension == extension
      }.map {|parser|
        Hammer::Parser.extensions_for(parser)
      }

      extensions.flatten.compact.uniq
    end

    def self.regex_for(filename, extension=nil)
      
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
        /#{filename}\.(#{extensions.join("|")})/
      elsif extension
        /#{filename}.#{extension}/
      else
        /#{filename}/
      end
    end

  end
end
