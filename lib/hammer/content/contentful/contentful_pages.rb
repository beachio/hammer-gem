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
      autobuild_content_types.each do |content_params|
        @params = content_params
        ContentProxy.add_paths(get_paths(content_params))
      end
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

    def get_paths(content_params)
      @params = content_params
      contents.map do |content|
        content_path(content)
      end
    end

    def contents
      cached = ContentCache.get('contents', @params)
      return cached if cached
      cf = ContentfulHelper.new(
        Settings.contentful,
        @params['space_name']
      )
      result = cf.send(@params['content_key'].to_sym) || []
      ContentCache.cache('contents', result, @params)
    end

    def content_path(content)
      path = content.homePage ? 'index.html' : ContentPages.new.content_path_concern(content, @params, 'contentful')
      path
    end

    def check_contentful_settings
      if autobuild_content_types.empty?
        []
      else
        ContentPages.new.building_contents(autobuild_content_types, contents, @input_directory, @output_directory, 'contentful')
      end
    end
  end
end