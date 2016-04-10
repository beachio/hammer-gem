# Contentful cache
# client.entries
# client.content_types

module Hammer
  class ContentfulCache
    def initialize(cache_key)
      @cache_key = cache_key
      @cache_path = cache_dir + '/' + cache_key
    end
  
    def response
      return unless File.exist?(@cache_path)
      @cache ||= YAML.load_file(@cache_path)
      HTTP::Response.new(@cache[:status], '1.0', @cache[:headers], @cache[:body])
    end
  
    def response=(value)
      response = { status: value.status.to_i, body: value.to_s, headers: value.headers }
      File.open(@cache_path, 'w') do |f|
        f.write(YAML.dump(response))
      end
      value
    end
  
    def cache_dir
      dir = if Settings.contentful['cache'].is_a?(String)
              File.expand_path(Settings.contentful['cache'])
            else
              Dir.tmpdir + '/hammer_contentful_cache'
            end
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      dir
    end
  end
end

module Contentful
  class Client
    def self.get_http(url, query, headers = {}, proxy = {})
      if Hammer::Settings.contentful['cache']
        cache_key = Digest::MD5.hexdigest({ u: url, q: query, h: headers }.to_s)
        cache = Hammer::ContentfulCache.new(cache_key)
        return cache.response if cache.response
      end
      if proxy[:host]
        response = HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).get(url, params: query)
      else
        response = HTTP[headers].get(url, params: query)
      end
      cache.response = response if Hammer::Settings.contentful['cache']
      response
    end
  end
end