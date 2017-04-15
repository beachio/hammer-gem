module Hammer
  class ContentPages

    def building_contents content_types, contents, input_dir, output_dir, service
      data = []
      content_types.each do |content_params|
        @params = content_params

        contents.each do |content|
          ContentProxy.register_variable(
              content_variable_name,
              content
          )
          text = parse_template(
              "#{input_dir}/#{@params['template']}",
              content_path_concern(content, @params, service),
              input_dir,
              output_dir
          )
          output_path = write_file(text, content, output_dir, service)
          ContentProxy.unregister_variable(content_variable_name)
          data << {
              filename: content_params['template'],
              output_filename: output_path,
              generated: true
          }
        end
      end
      data
    end

    def parse_template(template_path, filename, input_dir, output_dir)
      parsers = Hammer::Parser.for_filename(template_path)
      text = File.read(template_path)

      parsers.each do |parser_class|
        parser = parser_class.new
        parser.directory        = input_dir
        parser.input_directory  = input_dir
        parser.output_directory = output_dir

        parser.path = Pathname.new(File.join(input_dir, filename)).relative_path_from(Pathname.new(input_dir)).to_s

        text = parser.parse(text, parser.path)
      end
      text
    end

    def content_path_concern content, params, service
      path = ''
      if !params['urlAliasValue'].to_s.strip.empty?
        path = params['urlAliasValue'].to_s
        unless path.ends_with?('.html') || path.ends_with?('.htm')
          path += '.html'
        end
      elsif params['urlAliasSource']
        path_text = check_service_for_generate_path(service, content, params)
        path_text = content.first if path_text.nil?
        path = path_text.to_s.parameterize + '.html'
        if params['urlAliasPrefix'].to_s != ''
          path = "#{params['urlAliasPrefix'].to_s}/#{path}"
        end
      end
      path
    end

    def check_service_for_generate_path service, content, params
      if service == 'chisel'
        content.fields[params['urlAliasSource'].to_s]
      elsif service == 'contentful'
        content[params['urlAliasSource'].to_s]
      end
    end

    def write_file(text, content, output_dir, service)
      output_path = content_path_concern(content, @params, service)

      filepath = output_dir + '/' + output_path
      dir = File.dirname(filepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      File.open(filepath, 'w+') { |f| f.write(text) }
      output_path
    end

    def content_variable_name
      @params['content_key'].singularize.to_sym
    end
  end
end