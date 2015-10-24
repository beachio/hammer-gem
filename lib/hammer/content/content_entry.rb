require 'hammer/content/entry_errors/not_array'
module Hammer
  class ContentEntry
    attr_accessor :helper

    def initialize(defined_fields, helper)
      @fields = {}
      defined_fields.each do |field_name|
        @fields[field_name.to_s] = EmptyEntry.new(field_name.to_s, self)
      end
      @fields['homePage'] = false unless @fields['homePage'] == true
      self.helper = helper
    end

    def method_missing(method_name, *arguments, &block)
      result = get_field(method_name.to_s)
      result.nil? ? error(method_name.to_s) : result
    end

    def error(name)
      ex = SmartException.new(
        "(#{maybe_title}) You called '#{name}', but \
        there is no such field.",
        text: "No such field '#{name}', see list of available fields below:",
        list: fields
      )
      raise ex
    end

    def get_field(key)
      @fields[key]
    end

    def first
      @fields[@fields.keys.first] || hash
    end

    def set_field(name, value, type)
      entry_class = ContentEntry.identify(type)
      entry = entry_class.create(value, name.to_s, self)

      @fields[name.to_s] = entry
    end

    def [](key)
      get_field(key.to_s)
    end

    def to_h
      hash = {}
      @fields.each do |key, val|
        hash[key.to_sym] = val
      end
      hash
    end

    def fields
      @fields.keys
    end

    def maybe_title
      mt = @fields.find { |k, v| k =~ /name|title|slug/ && v.class == EntryText }
      mt ? mt[1] : first
    end

    class << self
      def identify(named_type)
        # TODO implement handlers for Number, Boolean, JSON
        {
          'Text'     => EntryText,
          'Date'     => EntryDate,
          'Location' => EntryLocation,
          'Link'     => EntryLink,
          'Array'    => EntryArray
        }[named_type.to_s] || EntryRaw
      end
    end
    
    module EntryBase
      def create(value, field_name, base)
        instance = self.new(value)
        instance.base = base if instance.respond_to?(:base)
        instance.field_name = field_name if instance.respond_to?(:field_name)
        instance
      end
    end

    class EntryText < String
      extend EntryBase
      include NotArray
    end

    class EntryNumber
      def self.create(value, base, field_name)
        value
      end
    end

    class EntryDate < Time
      include NotArray

      def self.create(value, base, field_name)
        self.parse(value)
      end
    end

    class EntryArray < Array
      attr_accessor :base, :field_name

      def self.create(content, base, field_name)
        itself = self.new()
        content.each do |element|
          entry_class = ContentEntry.identify(element[1])
          entry = entry_class.create(element[0], base, field_name)
          itself << entry
        end
        itself
      end

      def initalize(base, field_name)
        self.base = base
        self.field_name = field_name
      end

      def method_missing(method_name, *arguments, &block)
        ex = SmartException.new(
          "(#{@base.try(:maybe_title)}) You wanted to load field '#{method_name}', but \
          #{@field_name || 'parent field'} is array, not object. Most likely you should iterate \
          it or take some value with [] parentless",
          text: "You called `#{method_name}` on Array."
        )
        raise ex
        # raise ContentProxy.new.fill_exception(ex)
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
      extend EntryBase
      include NotArray
      attr_accessor :link, :base, :field_name

      def initialize(link)
        self.link = link
      end

      def method_missing(method_name, *arguments, &block)
        begin
          @entry ||= ContentfulEntryParser.new(base.helper).parse(link.resolve)
          @entry.send(method_name)
        rescue 
          EmptyEntry.new(method_name, field_name)
        end
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
          "(#{@parent.maybe_title}) You wanted to load field '#{method_name}' from '#{@field_name}', but \
          #{@field_name} is emty, so '#{method_name}' doesn't exist.",
          text: "You called `#{method_name}` on empty object."
        )
        raise ex
        # raise ContentProxy.new.fill_exception(ex)
      end
    end
  end
end