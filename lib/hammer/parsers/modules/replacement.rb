# TODO all over this.

module Hammer
  module Replacement
    def replace(regex, &block)
      puts "Replacing!"
    end
  end
end

module Hammer
  class Parser
    include Hammer::Replacement
  end
end