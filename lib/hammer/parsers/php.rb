class Hammer
  class PHPParser < HTMLParser

    def self.finished_extension
      'php'
    end
  end

  register_parser_for_extensions PHPParser, ['php']
  register_parser_as_default_for_extensions PHPParser, ['php']
end