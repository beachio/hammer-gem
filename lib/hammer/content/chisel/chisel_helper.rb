require_relative 'chisel_content_loader'
module Hammer
  class ChiselHelper < ChiselContentLoader
    attr_accessor :site_id, :collections, :models, :content_types, :content

    def initialize(settings)
      return {} if settings.nil? || settings.empty?
      @site_id = settings['site_id']
      @session_token = login(settings['login'], settings['password'])
      if @session_token != nil
        Settings.sessionToken = @session_token
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
      else
        ex = SmartException.new(
            "Invalid username/password",
            text: "Your username or password is incorrect. Please check and fix it."
        )
        fail ex
      end
    end

    def collections_of type
      if @models
        @models[type] ? Hammer::ChiselCollection.new(@models[type]['data']) : error(type)
      else
        ex = SmartException.new(
            "'#{type}' not found",
            text: "Perhaps you incorrectly specified 'parse_server_url' or 'parse_app_id'. Please check it and try again."
        )
        fail ex
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