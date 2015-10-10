require 'contentful'
require 'ostruct'
module Hammer
  class ContentfulHelper
    def initialize(config, space_name = 'default')
      return {} if config.nil? or config.empty?
      @config, @space = config, config['spaces'][space_name]
      @client = Contentful::Client.new(
        access_token: config['apiKey'],
        space: @space['id']
      )
    end

    def entries(query = {})
      @entries_raw ||= {}
      @entries_raw[query.hash] ||= @client.entries(query.merge(include: 2))
      parse_entries(@entries_raw[query.hash])
    end

    def entries_by_content_type(name)
      entries(content_type: content_type_id(name))
    end

    private

    # we catch requests to different content types and other spaces by this hack
    # like:
    # contentful.articles -> method_missing...
    # contentful.my_awesome_space.posts -> method_missing...
    def method_missing(method_name, *arguments, &block)
      key = method_name.to_s
      # lets check what user needs.
      # do we need to respond with different space?
      if @config['spaces'].has_key? key
        # return new instance of helper with different space
        @helpers ||= {}
        @helpers[key] ||= Hammer::ContentfulHelper.new(@config, key)
      # do we need a return entries of specific content type?
      elsif @space['contentTypes'].has_key? key
        if @space['contentTypes'][key].is_a? String
          content_type_name = @space['contentTypes'][key]
        else
          content_type_name = @space['contentTypes'][key]['name']
        end
        entries_by_content_type(content_type_name)
      else
        super
      end
    end

    def parse_entries(entries)
      entries.map do |entry|
        parse_entry(entry)
      end.compact
    end

    def parse_entry(entry)
      os = OpenStruct.new
      entry.fields.each do |field, content|
        os[field] = parse_content(content)
      end
      os
    end

    def parse_content(content)
      case content.class.to_s
      when /Array/
        then content.map { |x| parse_content(x) }
      when /Contentful::Asset/
        then content.image_url
      when /Contentful::Entry/
        then parse_entry(content)
      else content
      end
    end

    def content_type_id(name)
      return @content_type_ids[name] if @content_type_ids
      @content_type_ids = {}
      @client.content_types.each do |content|
        @content_type_ids[content.properties[:name]] = content.id
      end
      @content_type_ids[name]
    end
  end
end