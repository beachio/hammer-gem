module Hammer
  class EnvironmentParser
    class << self
      def pars(text, type)
        if (type == "slim")
          regular = /=\s*ENV\s*(.*)|<!--\s*@env\s*(.*?)\s*-->/
          slim_parse(regular, text)
        elsif (type == "html")
          regular = /<!--\s*@env\s*(.*?)\s*-->/m
          html_parse(regular, text)
        elsif (type == "js")
          regular = /'?"?\s*<!--\s*@env\s*(.*?)\s*-->.?"?'?/
          js_parse(regular, text)
        end
      end

      def html_parse(regular, text)
        text.scan(regular).each do |txt|
          variable_declaration = txt[0].to_s.sub(/<!--\s*@env/, "").sub(/\s*-->/, "").strip.split("|")
          key = variable_declaration[0].strip
          value = check_variable_value(variable_declaration, key)

          text = text.sub(regular, value)  if value
        end
        text
      end

      def slim_parse(regular, text)
        text.scan(regular).each do |txt|
          unless txt[0].nil?
            variable_declaration = txt[0].to_s.sub(/\['/, "").sub(/'\]/, "").strip.split("||")
          else
            variable_declaration = txt[1].to_s.sub(/<!--\s*@env/, "").sub(/\s*-->/, "").strip.split("|")
          end
          key = variable_declaration[0].strip
          value = check_variable_value(variable_declaration, key)

          text = text.sub(regular, value) if value
        end
        text
      end

      def js_parse(regular, text)
        text.scan(regular).each do |txt|
          variable_declaration = txt[0].to_s.sub(/<!--\s*@env/, "").sub(/\s*-->/, "").strip.split("|")
          key = variable_declaration[0].strip
          value = check_variable_value(variable_declaration, key)

          if (value.length != 0)
            value = "'#{value.gsub("'", "").gsub("\"", "")}'"
          end
          check_quotes = text.match(regular).to_s
          if (check_quotes[-1] != "'" and check_quotes[-1] != "\"")
            text = text.sub(/<!--\s*@env\s*(.*?)\s*-->/, value)
          else
            text = text.sub(regular, value)
          end
        end
        text
      end

      def check_variable_value variable_declaration, key
        if !Settings.environment.nil? && !Settings.environment[key].nil?
          return Settings.environment[key]
        elsif !variable_declaration[1].nil?
          return variable_declaration[1].strip
        end
      end


    end
  end
end