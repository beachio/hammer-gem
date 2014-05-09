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
  end
end