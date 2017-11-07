require 'active_support/inflector'
module Hammer
  class CockpitPages < Hammer::ContentGenerator
    register_content_source CockpitPages

    def autobuild_content_types
      return [] if Settings.cockpit.length == 0
      @content_types = Settings.cockpit['contentTypes']
      return [] unless @content_types.is_a?(Enumerable)
      @content_types.map do |content_name, content_params|
        next unless content_params['renderOnBuild'] == true
        content_params.merge('content_key' => content_name)
      end.compact
    end
      
    def register_file_paths
      @params = ContentPages.new.register_content_file_path(autobuild_content_types, 'cockpit')
    end

    def generate_pages
      # example params
      # {
      #  "name"=>"NU Container",
      #  "template"=>"templates/_container.slim",
      #  "urlAliasSource"=>"title",
      #  "renderOnBuild"=>true,
      # }
      data = check_cockpit_settings

      { cockpit: data }
    end

    def check_cockpit_settings
      if autobuild_content_types.empty?
        []
      else
        ContentPages.new.building_contents(autobuild_content_types, @input_directory, @output_directory, 'cockpit')
      end
    end

  end
end