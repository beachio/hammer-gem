module Hammer
  module Ignore

    def read_ignore_file file
      @ignore_regexes = []
      return true unless File.exist? file
      lines = File.open(file).read.split("\n")
      @ignore_regexes = lines.map {|line| regex_for(line)}.compact
    end

    def ignore? path
      return true if path.end_with? '.rb'
      return true if path.start_with? "Build"

      return true if path =~ /\/\.git\//
      return true if path =~ /\/\.svn\//
      return true if path =~ /\.DS_Store/
      return true if path =~ /\.sass-cache/

      @ignore_regexes.each do |regex|
        return true if regex.match(path)
      end

      # return true if File.basename(path).start_with? "_"
      return true if File.directory?(path)

      # .ht files are Apache!
      return true if File.basename(path).start_with?('.') && !File.basename(path).start_with?('.ht')

      # File without extension
      return true if !File.basename(path).include? "."

      # This is where I tried to ignore directories which start with a .
      # TODO: ignore directories which start with a .
      # files.reject! {|file| file.split("/")[0..-2].select { |directory| directory.start_with? "."}.length > 0}
      # files.reject! { |a| a =~ /\.{1,2}$/ }

      return false
    end

  private

    def regex_for line
      Regexp.new("^#{Regexp.escape(line.strip).gsub('\*','.*?')}$", Regexp::IGNORECASE)
    end

  end
end