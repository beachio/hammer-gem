class Hammer

  class HammerFile
    
    attr_accessor :hammer_project
    attr_accessor :filename, :full_path, :output_filename, :extension
    attr_accessor :raw_text, :text, :compiled_text

    def initialize(options={})
      super()
      @filename = options.delete(:filename) if options[:filename]
      @raw_text = options.delete(:text) if options[:text]

      if options[:hammer_project]
        @hammer_project = options.delete(:hammer_project)
        @hammer_project << self
      end
    end

    def filename=(filename)
      @filename = filename
      @extension = File.extname(@filename)[1..-1]
    end

  end
end