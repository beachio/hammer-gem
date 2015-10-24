require 'contentful'

module Hammer
  class ContentfulEntryParser
    attr_accessor :helper

    def initialize(helper)
      self.helper = helper
    end

    def parse(entry)
      content_type_id = entry.sys[:contentType].id
      fields = helper.content_type_fields(content_type_id)

      cont_entry = Hammer::ContentEntry.new(fields, helper)
      entry.fields.each do |field, content|
        content, type = parse_content(content)
        cont_entry.set_field(field, content, type)
      end

      cont_entry
    end

    private

    def parse_content(content)
      case content.class.to_s
      when /Array/ then
        [content.map { |x| parse_content(x) }.compact, 'Array']
      when /Contentful::Asset/ then
        [content.image_url, 'Text']
      when /Contentful::Entry/ then
        [parse(content), 'Entry']
      when /Contentful::Link/ then
        [content, 'Link']
      when /Fixnum/ then
        [content, 'Number']
      when /Float/ then
        [content, 'Number']
      else 
        [content, determine_type_by_content(content)]
      end
    end

    def determine_type_by_content(content)
      if content.class == String
        # Date, match by format:
        # 2015-10-23T16:26+03:00 or 2015-10-23T16:26:05+03:00
        date_match = content.match /^\d{4}-\d{1,2}-\d{1,2}T\d{1,2}:\d{1,2}:?\d{0,2}[\+-]\d{1,2}:\d{2}/
        if date_match && date_match[0] == content
          return 'Date'
        else
          return 'Text'
        end
      elsif content.class == Hash
        # match location
        # should have 'lat' and 'lon' keys
        return 'Location' if content.keys.sort == ['lat', 'lon']
        # else it is JSON
        return 'JSON'
      end
    end
  end
end