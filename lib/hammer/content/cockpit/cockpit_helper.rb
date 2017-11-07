require 'http'

module Hammer
  class CockpitHelper
    attr_accessor :url, :token, :collections

    def initialize(settings)
      @url = settings['apiUrl']
      @token = settings['apiKey']
      settings['contentTypes'].each do |key, type|
        type = type['name'] if type.class.to_s =~ /Hash/i
        self.class.send(:define_method, key) do
          collections_of(type)
        end
      end
      @collections = {}
    end

    def collections_of(type)
      return @collections[type] if @collections[type]
      endpoint = "#{url}/api/collections/get/#{type}"
      collection = JSON.parse(HTTP.get(endpoint, params: { token: token }))

      collections = []
      collection['entries'].each do |raw|
        collections << Hammer::CockpitEntry.new(raw, @url, type)
      end

      @collections[type] = Hammer::CockpitCollection.new(collections)
    end
  end
end