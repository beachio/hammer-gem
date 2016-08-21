require 'http'

module Hammer
  class ChizelHelper

    attr_accessor :url, :applicationId

    def initialize(settings)
      @url = settings['apiURL']
      @applicationId = settings['applicationId']
      # @clientSecret = settings['clientSecret']

      settings['contentTypes'].each do |key, type|
        self.class.send(:define_method, key) do
          collections_of(type)
        end
      end
    end

    def collections_of(type)
      return @collections[type] if @collections[type]
      endpoint = "#{url}/classes/#{type}"
      @collections[type] = JSON.parse(HTTP.get(endpoint, params: { "X-Parse-Application-Id" => applicationId})).map do |raw|
        Hammer::ChizelEntry.new(raw, @url, type)
      end
    end   

  end
end
