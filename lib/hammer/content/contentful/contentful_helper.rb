require 'contentful'
module Hammer
  class ContentfulHelper
    def initialize(config, space_name = 'default')
      return {} if config.nil? or config.empty?
      @config, @space = config, config['spaces'][space_name]
      @client = Contentful::Client.new(
        access_token: config['apiKey'],
        space: @space['id']
      )
      @space_helpers = { space_name => self }
    end

    def entries(query = {})
      @entries_raw ||= {}
      @entries_raw[query.hash] ||= @client.entries(query.merge(include: 2))
      parse_entries(@entries_raw[query.hash])
    end

    def entries_by_content_type(name)
      name = name.to_s
      if @space['contentTypes'].has_key? name
        if @space['contentTypes'][name].is_a? String
          content_type_name = @space['contentTypes'][name]
        else
          content_type_name = @space['contentTypes'][name]['name']
        end
        return entries(content_type: content_type_id(content_type_name))
      end
      nil
    end

    private

    # we catch requests to different content types and other spaces by this hack
    # like:
    # contentful.articles -> method_missing...
    # contentful.my_awesome_space.posts -> method_missing...
    def method_missing(method_name, *arguments, &block)
      # if user tried to query existing space or content type, return it to him
      switch_space(method_name) || entries_by_content_type(method_name) || super
    end

    def switch_space(space_name)
      space_name = space_name.to_s
      return unless @config['spaces'].has_key? space_name
      @space_helpers[key] ||= Hammer::ContentfulHelper.new(@config, space_name)
    end

    def parse_entries(entries)
      content_parser = ContentfulEntryParser.new
      entries.map do |entry|
        content_parser.parse(entry)
      end.compact
    end

    def content_type_id(name)
      content_type_ids[name]
    end

    def content_type_name(id)
      content_type_ids.key(id)
    end

    def content_type_ids
      return @content_type_ids if @content_type_ids
      @content_type_ids = {}
      @client.content_types.each do |content|
        @content_type_ids[content.properties[:name]] = content.id
      end
      @content_type_ids
    end
  end
end