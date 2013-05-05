class Hammer

  class HammerParser
    
    include Templatey
    
    attr_accessor :hammer_project, :variables

    def initialize(hammer_project = nil, hammer_file = nil)
      @text = ""
      @hammer_project = hammer_project if hammer_project
      @hammer_file = hammer_file if hammer_file
    end

    def text=(text)
      @text = text
    end


    attr_reader :hammer_file
    def hammer_file=(hammer_file)
      @hammer_file = hammer_file

      @text = @hammer_file.raw_text
      @filename = hammer_file.filename
    end
    
    def add_file(filename, text)
      file = @hammer_project.hammer_files.select{|file| file.filename == filename}[0]
      if file == nil
        file = HammerFile.new({:filename => filename, :text => text, :hammer_project => @hammer_project})
        file.is_a_compiled_file = true
      end
      return file
    end
    
    def text
      @text ||= ""
    end
    
    def production?
      @hammer_project.production
    end
    
    def filename
      @filename ||= @hammer_file.filename
    end
    
    def path_to(hammer_file)
      them = Pathname.new(hammer_file.finished_filename)
      me =  Pathname.new(File.dirname(self.filename))
      path = them.relative_path_from(me)
      path
    end
    
    def add_wildcard_dependency(tag, type)
      @hammer_project.cacher.add_wildcard_dependency(self.hammer_file.filename, tag, type)
    end
    
    def add_file_dependency(file)
      @hammer_project.cacher.add_file_dependency(self.hammer_file.filename, file.filename)
    end
    
    def _find_files(filename, extension=nil)
      # Convert relative paths to simple directories and filenames.
      filename = filename.gsub("../", "").gsub("./", "")
      files = @hammer_project.find_files(filename, extension)
      files      
    end
    
    def find_file_without_adding_dependency(filename, extension=nil)
      _find_files(filename, extension)[0]
    rescue => e
      nil
    end
    
    def find_files(filename, extension=nil)
      add_wildcard_dependency(filename, extension)
      return _find_files(filename, extension)
    end
    
    def find_file(filename, extension=nil)
      file = _find_files(filename, extension)[0]
      add_file_dependency(file)
      return file
    rescue => e
      puts e.message
      puts e.backtrace
      nil
    end
    
    def error(text, line_number, hammer_file=nil)
      @hammer_file.error = Hammer::Error.new(text, line_number, hammer_file)
      raise @hammer_file.error
    end
    
    def replace(regex, &block)
      lines = []
      if text.scan(regex).length > 0
        line_number = 0
        @text = text.split("\n").map { |line| 
          line_number += 1
          line.gsub(regex) { |match|
            begin 
              block.call(match, line_number) 
            rescue => error_message
              error(error_message, line_number)
            end
          }
        }.join("\n")
      end
      return
    end
    
    def parse
      raise "Base HammerParser#parse called"
    end
  end

end