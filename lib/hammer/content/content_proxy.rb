module Hammer
  class ContentProxy
    def initialize
    end

    def contentful
      @contentful ||= Hammer::ContentfulHelper.new(Settings.contentful)
    end

    def markdown(text)
      Hammer::MarkdownParser.new.parse(text) if text
    end
  end
end