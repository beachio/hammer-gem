# TODO all over this.

module Hammer
  module Replacement
    def replace(text, regex, &block)
      result = text
      lines = []
      if text.to_s.scan(regex).length > 0
        @line_number = 0
        result = text.to_s.split("\n").map { |line| 
          @line_number += 1
          line.gsub(regex).each do |match|
            block.call(match, @line_number) 
          end
        }.join("\n")
      end
      return result
    end

  end
end

module Hammer
  class Parser
    include Hammer::Replacement
  end
end