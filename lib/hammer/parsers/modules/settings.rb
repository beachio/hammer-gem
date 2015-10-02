require 'json'
module Hammer
  class Settings
    class << self
      attr_accessor :input_directory

      def sourcemaps
        config['sourcemaps']
      end
  
      def autoprefixer
        config['autoprefixer']
      end

      def config
        return @config if @config
        config_file = input_directory + '/hammer.json'
        if File.exist?(config_file)
          @config = JSON.parse(File.read(config_file)) rescue default_config
        else
          default_config
        end
      end

      def default_config
        { 'sourcemaps' => true, 'autoprefixer' => false }
      end
    end
  end
end