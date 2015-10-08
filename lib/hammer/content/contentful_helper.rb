require 'contentful'
require 'ostruct'
require 'pry'
module Hammer
  class ContentfulHelper
    def initialize(config)
      return unless config
      @client = Contentful::Client.new(
        access_token: config['apiKey'],
        space: config['spaces']['default']['id']
      )
    end

    def entries
      @entries_raw ||= @client.entries
      parse_entries(@entries_raw)
    end

    private

    def parse_entries(entries)
      return @entries_parsed if @entries_parsed
      @entries_parsed = entries.map do |entry|
        parse_entry(entry)
      end.compact
    end

    def parse_entry(entry)
      pe = OpenStruct.new
      entry.fields.each do |field, content|
        # binding.pry
        pe[field] = parse_content(content)
      end
      pe
    end

    def parse_content(content)
      case content.class.to_s
      when /Array/
        then content.map { |x| parse_content(x) }
      when /Contentful::Asset/
        then content.image_url
      when /String|Fixnum|Float|Bignum|BigDecimal/
        then content
      else
        nil
      end
    end
  end
end