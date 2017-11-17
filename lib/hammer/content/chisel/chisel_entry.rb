module Hammer
  class ChiselEntry
    attr_accessor :fields

    def initialize(fields)
      @fields = fields
    end

    def method_missing(method_name, *args)
      if method_name.to_s[-1..-1] == '?'
        return field_exist?(method_name.to_s.sub('?',''))
      elsif self.fields.has_key? method_name.to_s
        columns method_name.to_s, self.fields
      else
        error(method_name)
      end
    end

    def field_exist?(name)
      if self.fields.has_key? name.to_s
        field = columns(name.to_s, self.fields)
        return false if field.class.to_s =~ /EmptyEntry/
        return !field.empty? if field.respond_to?(:empty?)
        !!field
      else
        return false
      end
    end

    define_method :columns do |field, fields|
      fields[field]
    end

    def error(name)
      ex = SmartException.new(
          "Column or content '#{name}' not found",
          text: "You called `#{name}` but there's no such registered column. See list below for all registered columns:",
          list: @fields.keys
      )
      fail ex
    end

  end
end