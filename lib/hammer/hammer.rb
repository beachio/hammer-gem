class Hammer

  @@after_compilers = {}
  def self.after_compilers
    @@after_compilers
  end

  @@pre_compilers = {}
  def self.pre_compilers
    @@pre_compilers
  end
  
  def self.register_parser_for_extensions(parser_class, extensions)
    @@parsers ||= []
    @@parsers << parser_class
    @@extensions_for ||= {}
    @@parsers_for ||= {}
    extensions.each do |extension|
      @@parsers_for[extension] ||= []
      @@parsers_for[extension] << parser_class
      @@extensions_for[parser_class] ||= []
      @@extensions_for[parser_class] << extension
    end
  end
  
  def self.register_parser_as_default_for_extensions(parser_class, extensions)
    @@default_parser_for ||= {}
    extensions.each do |extension|
      @@default_parser_for[extension] = parser_class
    end
  end

  def self.parser_for_extension(extension)
    @@default_parser_for[extension]
  end
  
  def self.parser_for_hammer_file(hammer_file)
    raise "Oh no" unless hammer_file
    parser = @@default_parser_for[hammer_file.extension].new(hammer_file.hammer_project)
    parser.text = hammer_file.raw_text
    parser.hammer_file = hammer_file
    parser
  end
  
  def self.possible_other_extensions_for(extension)
    extensions = []
    parsers = Hammer.parsers_for_extension(extension)
    parsers.each do |parser|
      @@extensions_for[parser].each do |extension|
        extensions << extension
      end
    end
    extensions << @@parsers.select {|parser|
      parser.finished_extension == extension
    }.map {|parser|
      @@extensions_for[parser]
    }.flatten.compact
  end

  def self.parsers_for_extension(extension)
    parsers = []
    new_extension = nil
    parser = Hammer.parser_for_extension(extension)
    
    return [] unless parser
    
    parsers << parser
    
    while new_extension != parser.finished_extension
      new_extension = parser.finished_extension
      if new_extension != extension
        parsers << Hammer.parser_for_extension(new_extension)
      end
    end
    
    parsers
  end
  
  def self.regex_for(filename, extension=nil)
    
    require "uri"
    filename = URI.parse(filename).path
    
    extensions = [*extension].compact
    extensions = extensions + possible_other_extensions_for(extension)
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

require File.join(File.dirname(__FILE__), "include")