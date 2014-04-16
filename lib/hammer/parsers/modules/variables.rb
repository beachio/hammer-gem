module Hammer
  module Variables
    @variables = {}
    attr_accessor :variables

    def set_variable(name, value)
      @variables ||= {}
      @variables[name] = value
    end

    def get_variable(name)
      @variables ||= {}
      @variables[name]
    end
  end
end