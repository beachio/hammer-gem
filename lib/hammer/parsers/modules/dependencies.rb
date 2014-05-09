require 'hammer/parsers/modules/finding_files'

module Hammer
  module Dependency

    include Hammer::FindingFiles
    include Hammer::Extensions # needed for FindingFiles. It's dumb.

    attr_accessor :dependencies, :wildcard_dependencies

    def find_file_with_dependency(tag, extension=nil)
      file = find_file(tag, extension)
      add_dependency(file)
      file
    end

    def find_files_with_dependency(tag, extension=nil)
      files = find_files(tag, extension)
      add_wildcard_dependency(tag, extension)
      files
    end

    def add_dependency(file, extension=nil)
      @dependencies ||= []
      @dependencies.push(file)
    end

    def add_wildcard_dependency(query, extension=nil)
      # if args[1].is_a? Array
      #   results = {args[0] => args[1]}
      # else
      # end

      results = find_files(query, extension)
      @wildcard_dependencies ||= {}
      @wildcard_dependencies[[query, extension]] = [*results]
    end

  end
end