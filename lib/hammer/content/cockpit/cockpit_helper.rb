require 'http'

module Hammer
  class CockpitHelper
    attr_accessor :url, :token, :collections

    def initialize(settings)
      @url = settings['apiUrl']
      @token = settings['apiKey']
      settings['contentTypes'].each do |key, type|
        self.class.send(:define_method, key) do
          collections_of(type)
        end
      end
      @collections = {}
    end

    def collections_of(type)
      return @collections[type] if @collections[type]
      endpoint = "#{url}/api/collections/get/#{type}"
      @collections[type] = JSON.parse(HTTP.get(endpoint, params: { token: token })).map do |raw|
        Hammer::CockpitEntry.new(raw, @url, type)
      end
    end
  end
end