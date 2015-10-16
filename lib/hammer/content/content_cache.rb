module Hammer
  class ContentCache
    attr_accessor :cached_variables

    def initialize
      self.cached_variables = {}
    end

    def cache_variable(key, content, *params)
      cached_variables[cache_key(key, params)] = content
    end

    def get_variable(key, *params)
      cached_variables[cache_key(key, params)]
    end

    def cache_key(key, params)
      key = key.to_s
      key << params.hash.to_s unless params.empty?
    end

    class << self
      def cache(key, content, *params)
        $content_cache ||= ContentCache.new
        $content_cache.cache_variable(key, content, *params)
        content
      end

      def get(key, *params)
        $content_cache ||= ContentCache.new
        $content_cache.get_variable(key, *params)
      end

      def flush!
        $content_cache = nil
        $content_cache = ContentCache.new
      end
    end
  end
end