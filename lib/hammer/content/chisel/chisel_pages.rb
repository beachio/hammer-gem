require 'active_support/inflector'
module Hammer
  class ChiselPages < Hammer::ContentGenerator
    register_content_source ChiselPages

    attr_accessor :collection, :models

    def autobuild_content_types
      return [] if Settings.chisel.length == 0
      @content_types = Settings.chisel['contentTypes']
      return [] unless @content_types.is_a?(Enumerable)
      @content_types.map do |content_name, content_params|
        next unless content_params['renderOnBuild'] == true
        content_params.merge('content_key' => content_name)
      end.compact
    end

    def register_file_paths
      autobuild_content_types.each do |content_params|
        @params = content_params
        ContentProxy.add_paths(get_paths(content_params))
      end
    end

    def get_paths(content_params)
      @params = content_params
      contents.map do |content|
        content_path(content)
      end
    end

    def generate_pages
      content_loader = Hammer::ChiselContentLoader.new
      @collection = content_loader.get_content_for_site(Settings.chisel['site_id'])

      if @collection
        @models = content_loader.ensure_models_content(@collection)
      end

      data = check_chisel_settings

      { chisel: data }
    end


    def contents
      cached = ContentCache.get('contents', @params)
      return cached if cached
      ch = ChiselHelper.new(Settings.chisel)
      result = ch.send(@params['content_key'].to_sym) || []
      ContentCache.cache('contents', result, @params)
    end

    def content_path content
      ContentPages.new.content_path_concern(content, @params, 'chisel')
    end

    def check_chisel_settings
      if autobuild_content_types.empty?
        []
      else
        ContentPages.new.building_contents(autobuild_content_types, contents, @input_directory, @output_directory, 'chisel')
      end
    end

  end
end
