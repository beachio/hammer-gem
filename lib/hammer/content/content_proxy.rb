module Hammer
  class ContentProxy
    include Hammer::FindingFiles
    @@variables = { }

    def contentful
      @contentful ||= Hammer::ContentfulHelper.new(
        Settings.contentful,
        'default',
        self
      )
    end

    def cockpit
      @cockpit ||= Hammer::CockpitHelper.new(Settings.cockpit)
    end

    def chizel
      @chizel ||= Hammer::ChizelHelper.new(Settings.chizel)
    end

    def markdown(text)
      Hammer::MarkdownParser.new.parse(text) if text
    end

    def path(file)
      find_file(file)
    end

    def react_component(name, params)
      "<!-- @react_component '#{name}', #{params.to_json} -->"
    end

    # hack to return "registered variables" and "smart errors"
    def method_missing(method_name, *arguments, &block)
      @@variables[method_name] || error(method_name.to_s)
    end

    def error(name)
      ex = SmartException.new(
        "Variable '#{name}' doesn't exists. Probably you misspelled or forgot \
        to define it.",
        text: "Undefined variable #{name}. See below list of pre-defined variables:",
        list: @@variables.keys - ['autogenerated_content_files'] + ['contentful']
      )
      raise ex
    end

    class << self
      def register_variable(name, value)
        @@variables[name] = value
      end

      def unregister_variable(name)
        @@variables.delete(name)
      end

      def add_paths(paths)
        @@variables['autogenerated_content_files'] ||= []
        @@variables['autogenerated_content_files'].concat(paths)
      end

      def find_file(filename)
        return nil unless @@variables['autogenerated_content_files']
        @@variables['autogenerated_content_files'].select do |path|
          path.match(filename)
        end.max_by(&:length)
      end
    end
  end
end