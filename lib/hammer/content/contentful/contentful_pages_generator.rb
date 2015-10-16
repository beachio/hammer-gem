require 'active_support/inflector'
module Hammer
  class ContentfulPagesGenerator
    def initialize(input_directory, output_directory)
      @input_directory = input_directory
      @output_directory = output_directory
    end

    def self.autobuild_types
      return [] unless Settings.contentful['spaces'].is_a?(Hash)
      content_types = []
      Settings.contentful['spaces'].each do |space_name, space_params|
        next unless space_params['contentTypes'].is_a?(Hash)
        space_params['contentTypes'].each do |content_key, params|
          next unless params.is_a?(Hash) && params['renderOnBuild']
          content_types << params.merge(
            'space_name' => space_name,
            'content_key' => content_key
          )
        end
      end
      content_types
    end

    def generate(content_params)
      @params = content_params
      # example params
      # {
      #  "name"=>"NU Container",
      #  "template"=>"templates/_container.slim",
      #  "urlAliasSource"=>"title",
      #  "renderOnBuild"=>true,
      #  "space_name"=>"default",
      #  "content_key"=>"containers"
      # }
      data = {}
      contents.each do |content|
        ContentProxy.register_variable(
          content_variable_name,
          content
        )
        text = parse_template("#{@input_directory}/#{@params['template']}")
        write_file(text, content)
        ContentProxy.unregister_variable(content_variable_name)
      end

      data
    end

    def get_paths(content_params)
      @params = content_params
      contents.map do |content|
        content_path(content)
      end
    end

    def contents
      cached = ContentCache.get('contents', @params)
      return cached if cached
      cf = ContentfulHelper.new(
        Settings.contentful,
        @params['space_name']
      )
      result = cf.send(@params['content_key'].to_sym) || []
      ContentCache.cache('contents', result, @params)
    end

    def content_variable_name
      @params['content_key'].singularize.to_sym
    end

    def parse_template(template_path)
      parsers = Hammer::Parser.for_filename(template_path)
      text = File.read(template_path)
      parsers.each do |parser_class|
        parser = parser_class.new
        parser.directory        = @input_directory
        parser.input_directory  = @input_directory
        parser.output_directory = @output_directory
        parser.path = template_path.sub(@input_directory + '/', '')

        text = parser.parse(text, template_path)
      end
      text
    end

    def write_file(text, content)
      filepath = @output_directory + '/' + content_path(content)
      dir = File.dirname(filepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      File.open(filepath, 'w+') { |f| f.write(text) }
    end

    def content_path(content)
      if content.homePage
        path = 'index.html'
      elsif !@params['urlAliasValue'].to_s.strip.empty?
        path = @params['urlAliasValue'].to_s
        unless path.ends_with?('.html') || path.ends_with?('.htm')
          path += '.html'
        end
      elsif @params['urlAliasSource']
        path_text = content[@params['urlAliasSource'].to_s]
        path_text = (content.first || rand(100)) if path_text.nil?
        path = path_text.to_s.parameterize + '.html'
        if @params['urlAliasPrefix'].to_s != ''
          path = "#{@params['urlAliasPrefix'].to_s}/#{path}"
        end
      end
      path
    end
  end
end