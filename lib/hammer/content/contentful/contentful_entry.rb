require 'hammer/content/entry_errors/not_array'

module Hammer
  class ContentfulEntry
    attr_accessor :raw_entry
    attr_accessor :contentful_content_types
    attr_accessor :field_name

    def initialize(raw_entry, content_types, field_name = '')
      @raw_entry = raw_entry
      @contentful_content_types = content_types
      # entry also may be a field of another entry and vice versa
      # in this case entry_name == field_name
      @field_name = field_name 

      # format array of fields [ { id: 'title', type: 'Text' }, ... ] to
      # { 'title' => { id: 'title', type: 'Text' }, ... }
      content_type_id = @raw_entry.sys[:contentType].id
      @fields = {}
      content_types[:fields][content_type_id].each do |field|
        @fields[field.properties[:id]] = field.properties
      end

      # we parse field only if it was requested. store already parsed fields
      @ready_fields = {}
    end

    def homePage
      @fields.key?('homePage') ? !!@raw_entry.fields[:homePage] : false
    end

    def get_field(name)
      return @ready_fields[name] if @ready_fields.key?(name)
      field_class = ContentfulEntry.identify(@fields[name][:type])
      value = @raw_entry.fields[name.to_sym]
      @ready_fields[name] = field_class.create(value, name, self)
    end

    def field_exist?(name)
      return false unless @fields.key?(name)
      field = get_field(name)
      return false if field.class.to_s =~ /EmptyEntry/
      return !field.empty? if field.respond_to?(:empty?)
      !!field
    end

    def method_missing(method_name, *arguments, &block)
      method_name = method_name.to_s
      if method_name[-1..-1] == '?'
        return field_exist?(method_name.sub('?', ''))
      elsif @fields.key?(method_name)
        get_field(method_name)
      else
        ex = SmartException.new(
          "You called '#{method_name}', but \
          '#{method_name}' doesn't exist. (#{maybe_title})",
          text: "No such field `#{method_name}`. See available fields below:",
          list: entry_fields_list
        )
        raise ex
      end
    end

    def [](field_name)
      send(field_name)
    end

    def entry_fields_list
      @fields.keys
    end

    def maybe_title
      field_name = @fields.find do |k, _v|
        k =~ /name|title|slug/ && !@raw_entry.fields[k.to_sym].nil?
      end
      field_name ? send(field_name[0]) : first
    end

    def first
      value = @raw_entry.fields.find{ |_k, v| v.to_s != '' }
      value ? value[1] : @raw_entry.id
    end

    class << self
      def identify(named_type)
        # TODO implement handlers for Number, Boolean, Object (JSON)
        {
          'Symbol'   => EntryText,
          'String'   => EntryText,
          'Integer'  => EntryRaw,
          'Number'   => EntryRaw,
          'Date'     => EntryDate,
          'Location' => EntryLocation,
          'Link'     => EntryLink,
          'Asset'    => EntryLink,
          'Array'    => EntryArray,
          'Boolean'  => EntryRaw,
          'Object'   => EntryRaw,
          'Entry'    => ContentfulEntry
        }[named_type.to_s] || EntryRaw
      end

      def create(value, field_name, parent)
        new(value, parent.contentful_content_types, field_name)
      end
    end

    # TODO: move it away
    module EntryBase
      def create(value, field_name, parent)
        instance = self.new(value)
        instance.field_name = field_name if instance.respond_to?(:field_name)
        instance.parent_object = parent if instance.respond_to?(:parent_object)
        instance
      end
    end

    class EntryText < String
      extend EntryBase
      include NotArray
      attr_accessor :field_name, :parent_object
      def initialize(val)
        super(val.to_s)
      end
    end

    class EntryDate < Time
      include NotArray
      attr_accessor :field_name, :parent_object

      def self.create(value, field_name, parent)
        instance = self.parse(value)
        instance.field_name = field_name if instance.respond_to?(:field_name)
        instance.parent_object = parent if instance.respond_to?(:parent_object)
        instance
      end
    end

    class EntryArray < Array
      attr_accessor :field_name, :parent_object
      def self.create(content, field_name, parent_object)
        itself = self.new
        return itself if content.nil?
        itself.field_name = field_name
        itself.parent_object = parent_object
        content.each do |element|
          element_type = element.respond_to?(:type) ? element.type : element.class.to_s
          entry_class = ContentfulEntry.identify(element_type)
          entry = entry_class.create(element, field_name, parent_object)
          next if entry.class.to_s =~ /EmptyEntry/
          itself << entry
        end
        itself
      end

      def method_missing(method_name, *arguments, &block)
        ex = SmartException.new(
          "You wanted to load field '#{method_name}', but \
          #{@field_name || 'parent field'} is array, not object. Most likely \
          you should iterate it or take some value with [] parentless. \
          (#{@parent_object.maybe_title})",
          text: "You called `#{method_name}` on Array."
        )
        raise ex
        # raise ContentProxy.new.fill_exception(ex)
      end

      def order(field, order = 'asc')
        order = order.downcase
        
        raise SmartException.new("You tried to sort collection but used wrong \
          order parameter '#{order}'. (Contentful Entry: \
          #{parent_object.maybe_title})",
          text: 'Wrong order parameter. Allowed parameters are:',
          list: ['ASC', 'DESC']
        ) if order != 'asc' && order != 'desc'

        sorted = sort_by do |item|
          value = item[field]
          value.respond_to?(:downcase) ? value.downcase : value
        end
        order == 'asc' ? sorted : sorted.reverse
      end
    end

    class EntryLocation < Hash
      extend EntryBase

      def lat
        self['lat']
      end

      def lon
        self['lon']
      end

      alias_method :latitude, :lat
      alias_method :longitude, :lon
    end

    class EntryLink
      def self.create(value, field_name, parent_object)
        return EmptyEntry.new(field_name, parent_object) if value == nil
        entry = nil

        if value.respond_to?(:image_url)
          entry = EntryText.create(value.image_url, field_name, parent_object)
        elsif value.respond_to?(:resolve)
          begin
            value = value.resolve
          rescue
            entry = EmptyEntry.new(field_name, parent_object)
          end
        end

        entry || ContentfulEntry.new(
          value,
          parent_object.contentful_content_types,
          field_name
        )
      end
    end

    class EntryRaw
      def self.create(value, base, field_name)
        value
      end
    end

    class EmptyEntry < String
      def initialize(field_name, parent)
        @field_name = field_name
        @parent = parent
      end

      def each(&block)
      end

      def method_missing(method_name, *arguments, &block)
        if Settings.contentful['strict'] == false
          return EmptyEntry.new("#{@field_name}.#{method_name}", @parent)
        end
        ex = SmartException.new(
          "You wanted to load field '#{method_name}' from '#{@field_name}', but \
          #{@field_name} is emty, so '#{method_name}' doesn't exist. \
          (#{@parent.maybe_title})",
          text: "You called `#{method_name}` on empty object."
        )
        raise ex
      end
    end
  end
end
