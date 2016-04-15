module Hammer
  class CockpitEntry
    attr_accessor :raw_entry, :api_url, :entry_name

    def initialize(raw_entry, api_url, entry_name)
      @raw_entry = raw_entry
      @api_url = api_url
      @entry_name = entry_name
    end

    def id
      raw_entry['_id']
    end

    def created_at
      Time.at raw_entry['_created']
    end

    def updated_at
      Time.at raw_entry['_modified']
    end

    # access to article fields
    def method_missing(method_name, *arguments, &block)
      method_name = method_name.to_s
      if method_name.end_with?('?')
        return @raw_entry.key?(method_name.sub('?', ''))
      elsif @raw_entry.key?(method_name)
        parse_field(@raw_entry[method_name], method_name)
      else
        ex = SmartException.new(
          "You called '#{method_name}' on #{entry_name}, but " +
          "'#{method_name}' doesn't exist.",
          text: "No such field `#{method_name}`. See available fields below:",
          list: entry_fields_list
        )
        raise ex
      end
    end

    def entry_fields_list
      raw_entry.keys.select{ |x| !x.to_s.start_with?('_') }
    end

    def parse_field(content, field_name)
      return content unless content.is_a?(Hash)
      return self.class.new(
        { 'path' => "#{api_url}/#{content['path']}", 'title' => content['title'] },
        api_url, field_name
      ) if content['path']
      self.class.new(content, api_url, field_name)
    end
  end
end