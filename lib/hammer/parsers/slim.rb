require 'hammer/parser'
require 'slim'

module Hammer
  class SlimParser < Parser
    accepts :slim
    returns :html

    def parse(text)
      scope = {}
      Slim::Template.new {
        text
      }.render(scope)
    end

    def to_format(format)
      if format == :slim
        parse(@text)
      else
        @test
      end
    end
  end
end