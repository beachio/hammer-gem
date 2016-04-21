require 'active_support/inflector'
module Hammer
  class CockpitPages < Hammer::ContentGenerator
    register_content_source CockpitPages

    def autobuild_content_types
      return [] if Settings.cockpit.length == 0
      @content_types = Settings.cockpit['contentTypes']
      return [] unless @content_types.is_a?(Enumerable)
      @content_types.map do |content_name, content_params|
        next unless content_params['renderOnBuild'] == true
        content_params.merge('content_key' => content_name)
      end.compact
    end
      
    def register_file_paths
      autobuild_content_types.each do |content_params|
        ContentProxy.add_paths(get_paths(content_params))
      end
    end

    def get_paths(content_params)
      contents(content_params).map do |content|
        content_path(content, content_params)
      end
    end

    def generate_pages
      data = []
      autobuild_content_types.each do |content_params|
        # example params
        # {
        #  "name"=>"NU Container",
        #  "template"=>"templates/_container.slim",
        #  "urlAliasSource"=>"title",
        #  "renderOnBuild"=>true,
        # }
        contents(content_params).each do |content|
          ContentProxy.register_variable(
            content_params['content_key'].singularize.to_sym,
            content
          )
          text = parse_template(
            "#{@input_directory}/#{content_params['template']}",
            content_path(content, content_params)
          )
          output_path = write_file(text, content_path(content, content_params))

          ContentProxy.unregister_variable(
            content_params['content_key'].singularize.to_sym
          )
          data << {
            filename: content_params['template'],
            output_filename: output_path,
            generated: true
          }
        end
      end
      { cockpit: data }
    end

    def contents(params)
      cached = ContentCache.get('contents', params)
      return cached if cached
      cockpit = CockpitHelper.new(Settings.cockpit)
      result = cockpit.send(params['content_key']) || []
      ContentCache.cache('contents', result, params)
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

    def write_file(text, output_path)
      filepath = @output_directory + '/' + output_path
      dir = File.dirname(filepath)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      File.open(filepath, 'w+') { |f| f.write(text) }
      output_path
    end

    def content_path(content, params)
      chains = []
      chains << params['urlAliasPrefix'] if params['urlAliasPrefix'].to_s.length > 0
      
      if params['urlAliasSource'].to_s.length > 0
        slug = content.send(params['urlAliasSource'])
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
  end
end