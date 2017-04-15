module Hammer
  class ChiselCollection < Array

    def order field, direction
      raise SmartException.new("You tried to sort chisel collection but used wrong \
        order parameter '#{direction}'.",
                               text: 'Wrong order parameter. Allowed parameters are:',
                               list: ['ASC', 'DESC']
      ) unless direction =~ /asc|desc/i

      self.sort_by! { |elem| elem.send(field).downcase}
      self.reverse! if direction == 'desc'
      self
    end
  end
end
