require 'json'
module Hammer
  class Settings
    class << self
      attr_accessor :input_directory, :environment

      def sourcemaps
        config['sourcemaps'] || false
      end
  
      def autoprefixer
        config['autoprefixer'] || false
      end

      def contentful
        config['contentful'] || {}
      end

      # def environment
      #   config['environmentVariables']||{}
      # end

      def cockpit
        config['cockpit'] || {}
      end

      def output_dir
        config['buildDir']
      end

      def config_file
        "#{input_directory}/hammer.json"
      end

      def config
        return @config if @config
        if File.exist?(config_file)
          begin
            @config = JSON.parse(File.read(config_file))
          rescue Exception => e
            fail('Exception during reading hammer.json file. Please validate ' +
                  ' json by any validation tool.')
          end
        else
          default_config
        end
      end

      def default_config
        { 'sourcemaps' => false, 'autoprefixer' => false, 'contentful' => {} }
      end
    end
  end
end
