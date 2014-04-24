require 'hammer/templates/base'

module Hammer
  class CommandLineTemplate < Template

    def to_s
      "Command line results:"
      files.each do |file|
        line(file)
      end
    end

    def line(data)
      puts "#{data[:filename]}: compiled to #{data[:output_filename]}"
      # puts data
      data.keys.each do |key|
        puts "  #{key}: #{data[key]}" if data[key]
      end
    end

  end
end