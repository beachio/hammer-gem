require 'active_support/inflector'
module Hammer
  class ContentfulPages < Hammer::ContentGenerator
    register_content_source ContentfulPages

    def autobuild_content_types
      return [] unless Settings.contentful['spaces'].is_a?(Hash)
      return @content_types if @content_types
      @content_types = []
      Settings.contentful['spaces'].each do |space_name, space_params|
        next unless space_params['contentTypes'].is_a?(Hash)
        space_params['contentTypes'].each do |content_key, params|
          next unless params.is_a?(Hash) && params['renderOnBuild']
          @content_types << params.merge(
            'space_name' => space_name,
            'content_key' => content_key
          )
        end
      end
      @content_types
    end

    def handle_exeption(e)
      if e.class == Contentful::Unauthorized
        file = File.read(Settings.config_file)
        line = file.lines.find{ |x| x.match('"apiKey"\s*:') }
        raise SmartException.new(
          'Incorrect API key for Contentful',
          { text: 'please review credentials in hammer.json' },
          Settings.config_file,
          file.lines.index(line) + 1,
          @input_directory
        )
      elsif e.class == Contentful::NotFound
        raise SmartException.new(
          "Invalid space id for '#{@params['space_name']}' space. Contentful::NotFound error.",
          { text: 'please review credentials in hammer.json' },
          Settings.config_file,
          nil,
          @input_directory
        )
      else
        raise e
      end
    end
      
    def register_file_paths
      @params = ContentPages.new.register_content_file_path(autobuild_content_types, 'contentful')
    end

    def generate_pages
      # example params
      # {
      #  "name"=>"NU Container",
      #  "template"=>"templates/_container.slim",
      #  "urlAliasSource"=>"title",
      #  "renderOnBuild"=>true,
      #  "space_name"=>"default",
      #  "content_key"=>"containers"
      # }

      data = check_contentful_settings

      { contentful: data }
    end

    def check_contentful_settings
      if autobuild_content_types.empty?
        []
      else
        ContentPages.new.building_contents(autobuild_content_types, @input_directory, @output_directory, 'contentful')
      end
    end
  end
end