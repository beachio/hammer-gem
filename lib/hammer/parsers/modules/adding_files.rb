require 'tmpdir'

module Hammer
  module AddingFiles

    # At the moment, we give a parser :output_directory.
    # In future this could be actually made functional with a parser!
    # We could have a parser that goes through after all the other parsers
    # and creates all the created files. Or we could simply create it in the parser...

    attr_accessor :output_directory, :added_files

    def add_file(filename, text, filenames)
      @cache_directory ||= Dir.mktmpdir()

      path = File.join(@cache_directory, filename)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |file|
        file.write(text)
      end

      Hammer::Parser.parse_added_file(@input_directory, @cache_directory, filename, @output_directory, @optimized) do |text, data|
        File.open(path, 'w') do |file|
          file.write(text)
        end
      end

      FileUtils.mv(File.join(@cache_directory, filename), File.join(@output_directory, filename))

      @added_files ||= []
      @added_files.push({:filenames => filenames, :output_filename => filename, :filename => filename, :is_a_compiled_file => true})
      filename
    end

    # Read the contents of a file.
    # This is meant to replace File.open(file).open
    def read(filename)
      if File.exist? File.join(@directory, filename)
        File.open(File.join(@directory, filename)).read()
      # elsif @output_directory && File.exist?(File.join(@output_directory, filename))
      #   # elsif @output_directory && File.exist?(File.join(@output_directory, filename))
      #   File.open(File.join(@output_directory, filename)).read()
      else
        File.open(filename).read()
      end
    end

  end
end