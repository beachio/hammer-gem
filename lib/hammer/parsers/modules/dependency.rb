module Hammer
  module Dependency

    include FileFinder
    attr_accessor :dependencies, :wildcard_dependencies

    def find_file_with_dependency(tag, extension=nil)
      file = find_file(tag, extension)
      add_dependency(file)
      file
    end

    def find_files_with_dependency(tag, extension=nil)
      files = find_files(tag, extension)
      add_wildcard_dependency(files)
      files
    end

    def add_dependency(file, extension=nil)
      @dependencies ||= []
      @dependencies.push(file)
    end

    def add_wildcard_dependency(*args)
      if args[0].is_a? Array
        results = args
      else
        results = find_files(*args)
      end
      @wildcard_dependencies ||= {}
      @wildcard_dependencies[*args[0]] = results
    end

  end
end