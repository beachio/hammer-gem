require 'hammer/templates/base'

module Hammer
  class CommandLineTemplate < Template

    def to_s
      "Command line results:"
      files.each do |path, file|
        line(path, file)
      end
    end

    def line(path, data)
      puts "#{path}: compiled to #{data[:output_filename]}"
      puts data
      puts data[:error] if data[:error]
      data.keys.each do |key|
        puts "  #{key}: #{file[:key]}" if file[:key]
      end
    end

  end
end