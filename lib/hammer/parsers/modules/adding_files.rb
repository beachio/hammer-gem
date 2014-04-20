module Hammer
  module AddingFiles

    # At the moment, we give a parser :output_directory.
    # In future this could be actually made functional with a parser!
    # We could have a parser that goes through after all the other parsers
    # and creates all the created files. Or we could simply create it in the parser...

    attr_accessor :output_directory 

    def output_directory
      @output_directory ||= Dir.mktmpdir
    end

    def add_file(filename, text)
      path = File.join(output_directory, filename)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |file|
        file.write(text)
      end
      @added_files ||= {}
      @added_files[filename] = path
    end

  end
end