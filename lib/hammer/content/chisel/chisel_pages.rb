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
      @params = ContentPages.new.register_content_file_path(autobuild_content_types, 'chisel')
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

    def check_chisel_settings
      if autobuild_content_types.empty?
        []
      else
        ContentPages.new.building_contents(autobuild_content_types, @input_directory, @output_directory, 'chisel')
      end
    end

  end
end
