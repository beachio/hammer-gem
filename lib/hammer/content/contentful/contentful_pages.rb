require 'active_support/inflector'
module Hammer
  class ContentfulPages < Hammer::ContentGenerator
    register_content_source ContentfulPages

    def autobuild_content_types
      return [] unless Settings.contentful['spaces'].is_a?(Hash)
      return @content_types if @content_types
      @content_types = []
      Settings.contentful['spaces'].each do |space_name, space_params|
        next unless space_params['contentTypes'].is_a?(Hash)
        space_params['contentTypes'].each do |content_key, params|
          next unless params.is_a?(Hash) && params['renderOnBuild']
          @content_types << params.merge(
            'space_name' => space_name,
            'content_key' => content_key
          )
        end
      end
      @content_types
    end

    def handle_exeption(e)
      if e.class == Contentful::Unauthorized
        file = File.read(Settings.config_file)
        line = file.lines.find{ |x| x.match('"apiKey"\s*:') }
        raise SmartException.new(
          'Incorrect API key for Contentful',
          { text: 'please review credentials in hammer.json' },
          Settings.config_file,
          file.lines.index(line) + 1,
          @input_directory
        )
      elsif e.class == Contentful::NotFound
        raise SmartException.new(
          "Invalid space id for '#{@params['space_name']}' space. Contentful::NotFound error.",
          { text: 'please review credentials in hammer.json' },
          Settings.config_file,
          nil,
          @input_directory
        )
      else
        raise e
      end
    end
      
    def register_file_paths
      autobuild_content_types.each do |content_params|
        @params = content_params
        ContentProxy.add_paths(get_paths(content_params))
      end
    end

    def generate_pages
      data = []
      autobuild_content_types.each do |content_params|
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
      { contentful: data }
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

    def write_file(text, content)
      output_path = content_path(content)

      filepath = @output_directory + '/' + output_path
      dir = File.dirname(filepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      File.open(filepath, 'w+') { |f| f.write(text) }
      output_path
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
        path_text = content.first if path_text.nil?
        path = path_text.to_s.parameterize + '.html'
        if @params['urlAliasPrefix'].to_s != ''
          path = "#{@params['urlAliasPrefix'].to_s}/#{path}"
        end
      end
      path
    end
  end
end