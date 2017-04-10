module Hammer
  class ChiselMedia
  attr_accessor :file, :type, :collections

    def initialize file, type
      @file = file
      @type = type
    end

    def url
      @file['url']
    end

    def urlPresent?
      @file['url'] ? true : false
    end

    def is_image?
      media_type == 'image'
    end

    def is_video?
      media_type == 'video'
    end

    def is_audio?
      media_type == 'audio'
    end

    private

    def method_missing method_name, *args
      ex = SmartException.new(
          "Method #{method_name} was not found for Chisel Media content.",
          text: "You called `#{method_name}` but there's no such registered methods. See list below for all availeable methods for this class:",
          list: ["url", "urlPresent?", "is_image?", "is_video?", "is_audio?"]
      )
      fail ex
    end

    def media_type
      @type.split('/')[0]
    end
  end
end