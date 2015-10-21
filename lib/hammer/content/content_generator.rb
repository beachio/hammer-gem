module Hammer
  class ContentGenerator
    @@sources = []

    def initialize(input_directory, output_directory)
      @input_directory = input_directory
      @output_directory = output_directory
    end

    def process
      results = {}
      @@sources.each do |generator_class|
        generator = generator_class.new(@input_directory, @output_directory)
        generator.register_file_paths
        results.merge! generator.generate_pages # might be in parallel
      end
      ContentCache.flush!
      results
    end

    def register_file_paths
    end

    def generate_pages
      fail 'method "generate_pages" must be implemented'
    end

    class << self
      def register_content_source(constant)
        @@sources << constant
      end
    end
  end
end