module Hammer
  class ContentfulHelper
    attr_accessor :content_proxy

    def initialize(config, space_name = 'default', proxy = nil)
      return {} if config.nil? or config.empty?
      @config, @space = config, config['spaces'][space_name]
      @client = Contentful::Client.new(
        access_token: config['apiKey'],
        space: @space['id']
      )
      @space_helpers = { space_name => self }
      @content_proxy = proxy if proxy
    end

    def entries(query = {})
      @entries_raw ||= {}
      @entries_raw[query.hash] ||= @client.entries(query.merge(include: 2))
      Hammer::ContentfulEntry::EntryArray.new(parse_entries(@entries_raw[query.hash]))
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

    def parse_entries(entries)
      entries.map do |entry|
        ContentfulEntry.new(entry, content_types)
      end.compact
    end

    def content_type_id(name)
      content_types[:names][name]
    end


    def content_types
      return @content_types if @content_types
      @content_types = { names: {}, fields: {} }
      @client.content_types.each do |content|
        name = content.name
        @content_types[:names][name] = content.id
        @content_types[:fields][content.id] = content.fields
      end
      @content_types
    end

    private

    # we catch requests to different content types and other spaces by this hack
    # like:
    # contentful.articles -> method_missing...
    # contentful.my_awesome_space.posts -> method_missing...
    def method_missing(method_name, *arguments, &block)
      # if user tried to query existing space or content type, return it to him
      switch_space(method_name) || \
        entries_by_content_type(method_name) || \
        error(method_name.to_s)
    end

    def error(name)
      ex = SmartException.new(
        "Space name or Content type '#{name}' not found",
        text: "You called `#{name}` but there's no such registered content \
        type or space. See below list of available content types.",
        list: @space['contentTypes'].keys
      )
      fail ex
    end

    def switch_space(space_name)
      space_name = space_name.to_s
      return unless @config['spaces'].key? space_name
      @space_helpers[key] ||= Hammer::ContentfulHelper.new(@config,
                                                           space_name,
                                                           @content_proxy)
    end
  end
end
