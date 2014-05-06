require 'lib/hammer/templates/base'

module Hammer
  class CommandLineTemplate < Template
    def to_s
      text = []
      files.each do |data|
        # if data[:error]
          # text << "#{data[:filename]}: compiled to #{data[:output_filename]}"

          text << "#{data[:filename]} From cache!" if data[:from_cache]
          # text << "#{data[:filename]}: #{data}"
          # data.keys.each do |key|
          #   text << "  #{key}: #{data[key]}" if data[key]
          # end
        # end
      end
      text.join("\n")
    end
  end
end