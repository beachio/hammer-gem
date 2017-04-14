require 'active_support/inflector'
module Hammer
  class ChiselPages < Hammer::ContentGenerator
    register_content_source ChiselPages

    attr_accessor :collection, :models

    def autobuild_content_types
      return [] if Settings.chisel.length == 0
      @content_types = Settings.chisel['contentTypes']
      return [] unless @content_types.is_a?(Enumerable)
      @content_types.map do |content_name, content_params|
        next unless content_params['renderOnBuild'] == true
        content_params.merge('content_key' => content_name)
      end.compact
    end

    def register_file_paths
      autobuild_content_types.each do |content_params|
        @params = content_params
        ContentProxy.add_paths(get_paths(content_params))
      end
    end

    def get_paths(content_params)
      @params = content_params
      contents.map do |content|
        content_path(content)
      end
    end

    def generate_pages
      data = []

      content_loader = Hammer::ChiselContentLoader.new
      @collection = content_loader.get_content_for_site(Settings.chisel['site_id'])

      if @collection
        @models = content_loader.ensure_models_content(@collection)
      end

      autobuild_content_types.each do |content_params|
        @params = content_params

        contents.each do |content|
          ContentProxy.register_variable(
              content_variable_name,
              content
          )
          text = parse_template(
              "#{@input_directory}/#{@params['template']}",
              content_path(content)
          )
          output_path = write_file(text, content)
          ContentProxy.unregister_variable(content_variable_name)
          data << {
              filename: content_params['template'],
              output_filename: output_path,
              generated: true
          }
        end
      end
      { chisel: data }
    end


    def contents
      cached = ContentCache.get('contents', @params)
      return cached if cached
      cf = ChiselHelper.new(Settings.chisel)
      result = cf.send(@params['content_key'].to_sym) || []
      ContentCache.cache('contents', result, @params)
    end

    def content_variable_name
      @params['content_key'].singularize.to_sym
    end

    def parse_template(template_path, filename)
      parsers = Hammer::Parser.for_filename(template_path)
      text = File.read(template_path)

      parsers.each do |parser_class|
        parser = parser_class.new
        parser.directory        = @input_directory
        parser.input_directory  = @input_directory
        parser.output_directory = @output_directory
        # parser.path = template_path.sub(@input_directory + '/', '')
        parser.path = Pathname.new(File.join(@input_directory, filename)).relative_path_from(Pathname.new(@input_directory)).to_s

        text = parser.parse(text, parser.path)
      end
      text
    end

    def content_path(content)
      if !@params['urlAliasValue'].to_s.strip.empty?
        path = @params['urlAliasValue'].to_s
        unless path.ends_with?('.html') || path.ends_with?('.htm')
          path += '.html'
        end
      elsif @params['urlAliasSource']
        path_text = content.fields[@params['urlAliasSource'].to_s]
        path_text = content.first if path_text.nil?
        path = path_text.to_s.parameterize + '.html'
        if @params['urlAliasPrefix'].to_s != ''
          path = "#{@params['urlAliasPrefix'].to_s}/#{path}"
        end
      end
      path
    end

    def write_file(text, content)
      output_path = content_path(content)

      filepath = @output_directory + '/' + output_path
      dir = File.dirname(filepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      File.open(filepath, 'w+') { |f| f.write(text) }
      output_path
    end

  end
end
