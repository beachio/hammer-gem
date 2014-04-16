# Optimizer module mixin. This goes directly into Parser as all parsers can be optimized.
# This causes an optimize(text) method to be called before parse(). If the parse() method has branches in it for optimizing anyway, you may not need an optimize() method.
# Usage:
# class Thing
#   def optimize(text)
#     return text
#   end
#   include Optimizer
# end

module Hammer
  module Optimizer
    
    attr_accessor :optimized
    def optimized?; optimized; end

    def self.included(base)
      _parse = base.instance_method(:parse)
      
      base.send :define_method, :parse do |text|
        parse = _parse.bind(self)
        text = parse.call(text)
        if self.respond_to?(:optimize) && self.optimized?
          return optimize(text) 
        else
          return text
        end
      end
    end
  end
end