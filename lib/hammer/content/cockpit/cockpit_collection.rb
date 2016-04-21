module Hammer
  class CockpitCollection < Array
    def order(field, direction = 'asc')
      raise SmartException.new("You tried to sort cockpit collection but used wrong \
        order parameter '#{direction}'.",
        text: 'Wrong order parameter. Allowed parameters are:',
        list: ['ASC', 'DESC']
      ) unless direction =~ /asc|desc/i

      self.sort_by! { |elem| elem.send(field) }
      self.reverse! if direction == 'desc'
      self
    end
  end
end