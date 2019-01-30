# Chisel cache
# client.entries
# client.content_types

module Hammer
  class ChiselCache
    def initialize(cache_key)
      @cache_key = cache_key
      @cache_path = cache_dir + '/' + cache_key
    end

    def results
      return unless File.exist?(@cache_path)
      @cache ||= YAML.load_file(@cache_path)
      @cache
    end

    def results=(value)
      response = value
      File.open(@cache_path, 'w') do |f|
        f.write(YAML.dump(response))
      end
      value
    end

    def cache_dir
      dir = if Settings.chisel['cache'].is_a?(String)
              File.expand_path(Settings.chisel['cache'])
            else
              Dir.tmpdir + '/hammer_chisel_cache'
            end
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      dir
    end
  end
end
