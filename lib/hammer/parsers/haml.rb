require "haml"

class HAMLHelper
  def initialize(instance)
    @instance = instance
  end
  
  def path(tag)
    file = @instance.find_file(tag)
    raise "Path tags: <b>#{h tag}</b> couldn't be found." unless file
    @instance.path_to(file)
  end
end

class Hammer
    
  class HAMLParser < HammerParser

    def self.finished_extension
      "html"
    end

    def to_html
      parse
    end
    
    def to_haml
      @raw_text
    end
    
    def parse
      convert(text)
    rescue Haml::SyntaxError => e
      puts e.message 
      raise Hammer::Error.new(e.message, e.line)
    end
    
    private
    
    def convert(text)
      # base = HAMLHelper.new(self)
      # Haml::Engine.new(text).render(base)
      Haml::Engine.new(text).to_html
    end
  end
  register_parser_for_extensions HAMLParser, ['haml']
  register_parser_as_default_for_extensions HAMLParser, ['haml']

end