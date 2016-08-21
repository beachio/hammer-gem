require 'json'
module Hammer
  class Settings
    class << self
      attr_accessor :input_directory

      def sourcemaps
        config['sourcemaps'] || false
      end
  
      def autoprefixer
        config['autoprefixer'] || false
      end

      def contentful
        config['contentful'] || {}
      end

      def cockpit
        config['cockpit'] || {}
      end

      def chizel
        config['chizel'] || {}
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
            fail('There was an error reading hammer.json file. Please validate ' +
                  ' json using a validation tool.')
          end
        else
          default_config
        end
      end

      def default_config
        { 'sourcemaps' => false, 'autoprefixer' => false, 'contentful' => {}, 'cockpit' => {}. 'chizel' => {} }
      end
    end
  end
end
