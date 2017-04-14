module Hammer
  class ChiselHelper < ChiselContentLoader
    attr_accessor :site_id, :collections, :models, :content_types, :content

    def initialize(settings)
      @site_id = settings['site_id']
      @collections = get_content_for_site(@site_id)
      if @collections
        @models = ensure_models_content(@collections)
      end

      settings['contentTypes'].each do |key, type|
        type = type['name'] if type.class.to_s =~ /Hash/i
        self.class.send(:define_method, key) do
          collections_of(type)
        end
      end
    end

    def collections_of type
      if @models[type]
        return @models[type]['data']
      else
        error(type)
      end
    end

    private

    def method_missing method_name, *args
      error(method_name)
    end


    def error method
      ex = SmartException.new(
          "Table '#{method}' not found",
          text: "You called `#{method}` but there's no such registered table. See list below for all registered columns:",
          list: @models.keys
      )
      fail ex
    end

  end
end