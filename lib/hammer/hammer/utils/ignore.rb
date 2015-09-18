module Hammer
  module Ignore

    # Files that will be used from a directory
    def files_from_directory(directory, ignore_file)
      files = Dir.glob(
        File.join(Shellwords.escape(directory), "/**/*"),
        File::FNM_DOTMATCH
      ).select { |f| File.file?(f) }
      regexes = ignore_regular_expressions_from_file(ignore_file)
      
      files.reject! {|file|
        path = file.gsub(directory+"/", "")
        ignore?(path)
      }

      files.reject! {|file|
        reject = false
        regexes.each do |regex|
          reject ||= file.match(regex)
        end
        reject
      }

      files
    end

    # Files that won't be used from a directory!
    def ignored_files_from_directory(directory, ignore_file)
      all = Dir.glob(File.join(Shellwords.escape(directory), "/**/*"), File::FNM_DOTMATCH)
      used = files_from_directory(directory, ignore_file)
      files = (all || []) - (used || [])

      files = files.reject {|file|
        ignore?(file)
      }
      files
    end

    def ignore_regular_expressions_from_file(file)
      ignore_regexes = []
      return [] unless File.exist? file
      lines = File.open(file).read.split("\n")
      lines.map {|line| regex_for(line)}.compact
    end

    def ignored_file? path
      return false if path.end_with? "."
      return false if File.directory?(path)
      # return false if !path.start_with?(@output_directory)
      return false if path.include?(".git")
      return false if path.include?(".esproj")

      return true
    end

    def ignore? path
      @ignore_paths ||= {}
      @ignore_paths[path] ||= _ignore? path
    end

    def _ignore? path

      return true if path.include?(".git")
      return true if path.include?(".esproj")

      return true if path.end_with? '.rb'
      return true if path.start_with? "Build"

      # return true if File.basename(path).start_with? "_"
      return true if File.directory?(path)

      # .ht files are Apache!
      basename = File.basename(path)
      return true if basename.start_with?('.') && !basename.start_with?('.ht')

      # File without extension
      return true if !basename.include? "."

      return true if !!(path =~ /\.git\/|\/\.svn\/|\.DS_Store|\.sass-cache/)
      # return true if !!(path =~ /\.git\//)
      # return true if !!(path =~ /\/\.svn\//)
      # return true if !!(path =~ /\.DS_Store/)
      # return true if !!(path =~ /\.sass-cache/)

      # This is where I tried to ignore directories which start with a .
      # TODO: ignore directories which start with a .
      # files.reject! {|file| file.split("/")[0..-2].select { |directory| directory.start_with? "."}.length > 0}
      # files.reject! { |a| a =~ /\.{1,2}$/ }

      return false
    end

  private

    def regex_for line
      Regexp.new("#{Regexp.escape(line.strip).gsub('\*','.*?')}$", Regexp::IGNORECASE)
    end

  end
end