module Hammer
  module FileFinder

    attr_accessor :filenames

    def find_files(filename, extensions)

      # TODO: Cache this method

      filename = clean(filename)
      regex = Hammer::Utils.regex_for(filename, extension)
      matches = filenames.select { |filename|
        match = filename =~ regex

        # straight_basename = false  # File.basename(file.filename) == filename
        # no_extension_required = extension.nil?
        # has_extension = File.extname(file.filename) != ""

        (File.extname(filename) != "" || extension.nil?) && (match)
      }.sort_by {|filename|
        filename.to_s
      }.sort_by { |filename|

        basename      = File.basename(filename)
        match         = basename == [filename, extension].compact.join(".")
        partial_match = basename == ["_"+filename, extension].compact.join(".")

        score = file.filename.split(filename).join.length

        if match
          score
        elsif partial_match
          score + 10
        else
          score + 100
        end

      }

      if matches && matches.length > 0 && !filename.include?('*')
        matches = matches[0..0]
      end

      return matches
    end
  private
    def clean(filename)
      filename = filename[1..-1] if filename.start_with? "/"
      filename
    end
  end
end