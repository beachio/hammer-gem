require 'amp'
require 'uglifier'

module Hammer
  class HTMLParser < Parser

    accepts :html
    returns :html

    if !defined? RELOADER_SCRIPT
      RELOADER_SCRIPT = "
        <!-- Hammer reload -->
          <script>
            setInterval(function(){
              try {
                if(typeof ws != 'undefined' && ws.readyState == 1){return true;}
                ws = new WebSocket('ws://'+(location.host || 'localhost').split(':')[0]+':35353')
                ws.onopen = function(){ws.onclose = function(){document.location.reload()}}
                window.onbeforeunload = function() { ws = null }
                ws.onmessage = function(){
                  var links = document.getElementsByTagName('link');
                    for (var i = 0; i < links.length;i++) {
                    var link = links[i];
                    if (link.rel === 'stylesheet' && !link.href.match(/typekit/)) {
                      href = link.href.replace(/((&|\\?)hammer=)[^\&]+/,'');
                      link.href = href + (href.indexOf('?')>=0?'&':'?') + 'hammer='+(new Date().valueOf());
                    }
                  }
                }
              }catch(e){}
            }, 1000)
          </script>
        <!-- /Hammer reload -->
      "
    end
    @@cached_files = {}
    @@minified_files = []

    #This was the old way we called .to_html - just doing the get_variables and includes. This means the includes are done and the includes with variables as input are all done recursively.
    #The downside of not doing this recursively is that we will probably have some problems with relative paths.
    # If you write <!-- @include a --> in an include, verify b/a.html gets used for index.html and a.html gets used for b/index.html
    #We now just File.open(file).read() when we do the include so this method is kind of irrelevant.
    # So we should check whether we should be using a different method for including includes than File.open(file).read for path reasons.
    # These files may also have to be partially-compiled before including, so their relative path tags are accurately ranked! That sort of thing.


    def to_format(format)
      if format == :html
        text = @text
        get_variables(text)
        text = includes(text)
        text = output_variables(text)
        text
      end

      # Second way: #{parse(@text)}
    end

    def parse(text, filename=nil)

      @text ||= text
      get_variables(text)

      text = path_tags(text)

      text = includes(text)

      get_variables(text)
      text = placeholders(text)

      get_variables(text)

      text = reload_tags(text)
      text = stylesheet_tags(text)
      text = javascript_tags(text)
      text = path_tags(text)
      text = output_variables(text)
      text = current_tags(text)
      text = ensure_text_has_no_leading_blank_lines(text)

      text = text[0..-2] if text.end_with? "\n"

      clean_uncompressed_assets() if optimized
      return text
    end

    def variables
      @variables ||= {}
    end

  private

    def clean_uncompressed_assets
      @@minified_files.each do |file|
        filepath = "#{output_directory}/#{file}"
        FileUtils.rm(filepath) if File.exist?(filepath)
      end
      @@minified_files = []
    end

    def placeholders(text)
      text = replace(text, /<!-- @placeholder (.*?) -->/) do |tag, line_number|
        options = tag.gsub("<!-- @placeholder ", "").gsub("-->", "").strip.split(" ")

        dimensions = options[0]
        text = ""
        alt = 'Placeholder Image'

        if options[1]
          text = options[1..-1].join(" ")
          alt = text.gsub('"', '')
          text = "&text=#{CGI.escape(text)}"
        end

        x = dimensions.split('x')[0]
        y = dimensions.split('x')[1] || x

        begin
          "<img src='http://placehold.it/#{x}x#{y}#{text}' width='#{x}' height='#{y}' alt='#{alt}' />"
        end
      end

      text = replace(text, /<!-- @kitten (\S*) -->/) do |tag, line_number|
        dimensions = tag.gsub("<!-- @kitten ", "").gsub("-->", "").strip
        x = dimensions.split('x')[0]
        y = dimensions.split('x')[1]
        "<img src='http://placekitten.com/#{x}/#{y}' width='#{x}' height='#{y}' alt='Meow' />"
      end

      text
    end

    def get_variables(text)
      replace(text, /<!-- \$(.*?) -->/) do |tag, line_number|
        variable_declaration = tag.gsub("<!-- $", "").gsub("-->", "").strip.split(" ")
        variable_name = variable_declaration[0]
        variable_value = variable_declaration[1..-1].join(' ')
        # If there's a |, this is a getter with a default!
        # TODO: Update the regex to disallow | characters.
        if !variable_value.start_with?("|") && variable_value != ""
          self.variables[variable_name] = variable_value
        end
        ""
      end
    end

    def output_variables(text)
      replace(text, /<!-- \$(.*?) -->/) do |tag, line_number|
        variable_declaration = tag.gsub("<!-- $", "").gsub(" -->", "").strip

        has_spaces = variable_declaration.include?(' ')

        variable_name = variable_declaration.split(" ")[0]
        variable_value = variable_declaration.split("|")[1..-1].join("|").strip rescue false

        is_a_getter_with_a_default = variable_declaration.split(" ")[1] == "|"
        if is_a_getter_with_a_default
          default = variable_declaration.split("|")[1..-1].join("|").strip rescue false
        end

        if has_spaces && !is_a_getter_with_a_default
          # Oh god it's a setter why are you still here
          self.variables[variable_name] = variable_declaration.split(" ")[1..-1].join(' ')
          ""
        elsif self.variables[variable_name] || default
          self.variables[variable_name] || default
        else
          raise "Variable <b>#{h variable_name}</b> wasn't set!"
        end
      end
    end

    def includes(text)
      while text.match /<!-- @include (.*?) -->/
        text = replace(text, /<!-- @include (.*?) -->/) do |tags, line_number|
          tags = tags.gsub("<!-- @include ", "").gsub("-->", "").strip.split(" ")
          tags.map do |query|
            if (query.start_with? "$")
              variable_value = variables[query[1..-1]]
              raise "Includes: Can't include <b>#{h query}</b> because <b>#{h query}</b> isn't set." unless variable_value
              query = variable_value
            end

            file = find_file(query, 'html')
            add_dependency(file)

            raise "Includes: File <b>#{h query}</b> couldn't be found." unless file

            parse_file(file, :html)
          end.compact.join("\n")
        end
      end
      text
    end

    def reload_tags(text)
      if optimized
        return text.gsub(/<!-- @reload -->/, "")
      else
        return text.gsub(/<!-- @reload -->/, RELOADER_SCRIPT)
      end
    end

    def alternative_path_tags(text)
      replace(text, /['|"]@path (.*?)['|"]/) do |tag, line_number|
        filename = tag[6..-2]

        filename = get_variable(filename) if filename.split("")[0] == "$"
        filename = filename.strip
        file = find_file(filename)
        raise "Path tags: <b>#{h filename}</b> couldn't be found." if !file

        [tag.split("")[0], path_to(file), tag.split("")[-1]].join()
      end
    end

    def path_tags(text)
      text = replace(text, /<!-- @path (.*?) -->/) do |tag, line_number|
        filename = tag.gsub("<!-- @path ", "").gsub("-->", "").strip

        filename = get_variable(filename) if filename.split("")[0] == "$"
        filename = filename.strip
        file = find_file(filename)
        raise "Path tags: <b>#{h filename}</b> couldn't be found." if !file

        path_to(file)
      end
      text = alternative_path_tags(text)
      text
    end

    def get_variable(variable_name)

      @variables ||= {}

      if variable_name.split("")[0] == "$"
        variable_name = variable_name.split("")[1..-1].join("")
      end
      variable_value = @variables[variable_name]
      if !variable_value
        raise "Variable <b>#{variable_name}</b> wasn't set!"
      end
      return variable_value
    end

    # Take a bunch of CSS or JS files and combine them into one 10981cd72e39481a723.js digest file.
    def add_file_from_files(files, format)
      return false if files == []
      @@minified_files.concat files
      # return false if files.collect(&:error) != []
      contents = []

      key = files.join(':') + ":#{format}"
      return @@cached_files[key] if @@cached_files[key]

      files.each do |file|
        # TODO: We need a better way of getting the compiled contents of a file.
        contents << parse_file(file, format)

        if format == :js
          contents << ";"
        end
      end
      contents = contents.join("\n\n\n\n")
      if format == :css
        engine = Sass::Engine.new(contents, syntax: :scss, style: :compressed)
        contents = engine.render
      elsif format == :js
        contents = Uglifier.compile(contents, mangle: false)
      end
      filename = Digest::MD5.hexdigest(contents)
      assets_directory = "#{output_directory}/assets"
      Dir.mkdir(assets_directory) unless Dir.exist?(assets_directory)
      file = add_file("assets/#{filename}.#{format}", contents, files)
      # file.source_files = files # TODO

      @@cached_files[key] = file

      file
    end

    # Used for both Javascript and stylesheet tags!
    def replace_header_tags(text, regex, format, &block)
      @header_tags ||= {}
      @header_tags[regex] ||= []

      replace(text, regex) do |tagged_path, line_number|
        results, tags, hammer_files, paths = [], [], [], [], []
        filenames = tagged_path.gsub(regex.to_s[/<!-- (.*?) /], "").gsub("-->", "").strip.split(" ")

        filenames.each do |filename|
          filename        = get_variable(filename) if filename.split("")[0] == "$"
          matching_files  = find_files_with_dependency(filename, format.to_s)
          name            = regex.to_s[/ (.*?) /].strip.gsub("@", "").capitalize
          raise "#{name} tags: <b>#{h filename}</b> couldn't be found." if matching_files.empty?
          hammer_files += matching_files
        end

        hammer_files_to_tag = []
        hammer_files.each do |file|
          # We don't want this if it's a compiled file, or if it's only an include!
          # next if file.is_a_compiled_file # TODO
          next if File.basename(file).start_with?("_")

          path = path_to(file)
          # TODO: WTF do these do
          next if @header_tags[regex].include?(path)
          @header_tags[regex] << path

          paths << path
          hammer_files_to_tag << file
        end

        if optimized
          file = add_file_from_files(hammer_files_to_tag, format)
          paths = [path_to(file)]
        end

        paths.map { |path| block.call(path) }.compact.join("\n")
      end
    end

    def stylesheet_tags(text)
      replace_header_tags(text, /<!-- @stylesheet (.*?) -->/, :css) do |path|
        "<link rel='stylesheet' href='#{path}'>"
      end
    end

    def javascript_tags(text)
      replace_header_tags(text, /<!-- @javascript (.*?) -->/, :js) do |path|
        "<script src='#{path}'></script>"
      end
    end

    def current_tags(text)
      Amp.compile(text, File.basename(filename), 'current')
    end

    def ensure_text_has_no_leading_blank_lines(text)
      text ||= ""
      while text.split(/\n|\t|\r/)[0] == ""
        text = text[1..-1]
      end
      text
    end

  end
end