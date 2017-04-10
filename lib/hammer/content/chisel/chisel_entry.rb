module Hammer
  class ChiselEntry
    attr_accessor :fields

    def initialize(fields)
      @fields = fields
    end

    def method_missing(method_name, *args)
      if self.fields.has_key? method_name.to_s
        columns method_name.to_s, self.fields
      else
        error(method_name)
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