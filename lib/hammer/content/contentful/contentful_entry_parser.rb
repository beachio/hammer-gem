require 'contentful'
require 'ostruct'

module Hammer
  class ContentfulEntryParser
    attr_accessor :max_level

    def initialize(max_level = 5)
      self.max_level = max_level
    end

    def parse(entry, level = 0)
      return OpenStruct.new if level >= max_level
      os = OpenStruct.new
      entry.fields.each do |field, content|
        os[field] = parse_content(content, level + 1)
      end
      # os['type'] = content_type_name(entry.sys[:contentType].sys[:id])
      os
    end

    private

    def parse_content(content, level = 0)
      case content.class.to_s
      when /Array/
        then content.map { |x| parse_content(x, level + 1) }.compact
      when /Contentful::Asset/
        then content.image_url
      when /Contentful::Entry/
        then parse(content, level + 1)
      when /Contentful::Link/ then
        return content if level >= max_level
        parse_content(content.resolve, level + 1) rescue nil
      else content
      end
    end
  end
end