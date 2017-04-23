require 'hammer/parser'
require 'jsx'
module Hammer
  class JSXParser < Parser
    accepts :jsx
    returns :js
    register_as_default_for_extensions :jsx

    alias_method :to_javascript, :parse

    def to_format(format)
      case format
      when :js
        parse(@text)
      when :jsx
        @text
      end
    end

    def parse(text, filename = nil)
      text = environment_variables(text)
      JSX.transform(text, strip_types: true, harmony: true)
    rescue ExecJS::ProgramError, ExecJS::RuntimeError => error
      line = error.message.scan(/on line ([0-9]*)/).flatten.first.to_s rescue nil
      message = error.message.split("Error: ")[1]
      message = "JSX Error: #{message}"
      # TODO: Do something with line!
      raise message
    end

    def environment_variables(text)
      text = EnvironmentParser.pars(text, "js")
      text
    end

  end
end
