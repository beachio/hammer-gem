module Hammer
  class ContentPages

    def building_contents content_types, input_dir, output_dir, service
      data = []
      @test = Hammer::ContentProxy.new()
      content_types.each do |content_params|
        @params = content_params

        contents(service).each do |content|
          ContentProxy.register_variable(
              content_variable_name,
              content
          )
          text = parse_template(
              "#{input_dir}/#{@params['template']}",
              check_service(content, service),
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

    def register_content_file_path autobuild_content_types, service
      autobuild_content_types.each do |content_params|
        @params = content_params
        ContentProxy.add_paths(get_paths(content_params, service))
      end
      @params
    end

    def get_paths(content_params, service)
      @params = content_params
      contents(service).map do |content|
        check_service(content, service)
      end
    end

    def contents service
      cached = ContentCache.get('contents', @params)
      return cached if cached
      helper = ensure_helper_service(service)
      result = helper.send(@params['content_key']) || []
      ContentCache.cache('contents', result, @params)
    end


    def ensure_helper_service service
      if service == 'contentful'
        ContentfulHelper.new( Settings.contentful, @params['space_name'])
      elsif service == 'chisel'
        ChiselHelper.new(Settings.chisel)
      elsif service == 'cockpit'
        CockpitHelper.new(Settings.cockpit)
      end
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

        text = parser.parse(text, parser.path, @test)
      end
      text
    end

    def content_path_concern content, service
      path = ''
      if service == 'contentful' && content.homePage
        path = 'index.html'
        return path
      end

      if !@params['urlAliasValue'].to_s.strip.empty?
        path = @params['urlAliasValue'].to_s
        unless path.ends_with?('.html') || path.ends_with?('.htm')
          path += '.html'
        end
      elsif @params['urlAliasSource']
        path_text = check_service_for_generate_path(service, content)
        path_text = content.first if path_text.nil?
        path = path_text.to_s.parameterize + '.html'
        if @params['urlAliasPrefix'].to_s != ''
          path = "#{@params['urlAliasPrefix'].to_s}/#{path}"
        end
      end
      path
    end

    def cockpit_content_path content
      chains = []
      chains << @params['urlAliasPrefix'] if @params['urlAliasPrefix'].to_s.length > 0

      if @params['urlAliasSource'].to_s.length > 0
        slug = content.send(@params['urlAliasSource'])
        slug = content.id if slug.to_s.length == 0
        slug
      else
        slug = content.id
      end
      chains << slug.downcase.parameterize

      path = chains.join('/')
      path << '.html' unless path =~ /(.html?)$/i
      path
    end

    def check_service_for_generate_path service, content
      if service == 'chisel'
        content.fields[@params['urlAliasSource'].to_s]
      elsif service == 'contentful'
        content[@params['urlAliasSource'].to_s]
      end
    end

    def check_service content, service
      if service == 'cockpit'
        cockpit_content_path(content)
      else
        content_path_concern(content, service)
      end
    end

    def write_file(text, content, output_dir, service)
      output_path = check_service(content, service)

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