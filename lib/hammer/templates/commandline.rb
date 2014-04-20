module Hammer
  class CommandLineTemplate < Template

    def to_s
      "Command line results:"
      files.each do |path, file|
        line(path, file)
      end
    end

    def line(path, file)
      puts "#{path}: #{" " * (14 - path.length.to_i)} #{file[:error] if file[:error]}"
      file.keys.each do |key|
        puts "  #{key}: #{file[:key]}" if file[:key]
      end
    end

  end
end