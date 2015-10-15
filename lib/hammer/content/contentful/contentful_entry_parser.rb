require 'contentful'
require 'ostruct'

module Hammer
  class ContentfulEntryParser
    def parse(entry)
      os = OpenStruct.new
      entry.fields.each do |field, content|
        os[field] = parse_content(content)
      end
      # os['type'] = content_type_name(entry.sys[:contentType].sys[:id])
      os
    end

    private

    def parse_content(content)
      case content.class.to_s
      when /Array/
        then content.map { |x| parse_content(x) }.compact
      when /Contentful::Asset/
        then content.image_url
      when /Contentful::Entry/
        then parse(content)
      when /Contentful::Link/
        then parse_content(content.resolve) rescue nil
      else content
      end
    end
  end
end