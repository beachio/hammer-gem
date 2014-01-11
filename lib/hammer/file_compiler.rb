module Hammer
  class FileCompiler

    def initialize(options)
      @hammer_file = options.fetch(:hammer_file)
      @hammer_project = options.fetch(:hammer_project)
    end

    def compile
      pre_compile
      compile_hammer_file
      after_compile
    end

  private

    ## Compilation stages: Before, during and after.
    def pre_compile
      todos = TodoParser.new(:hammer_project => @hammer_project, :hammer_file => @hammer_file).parse()
      todos.each do |line_number, messages|
        messages.each do |message|
          @hammer_file.messages.push({:line => line_number, :message => message, :html_class => 'todo'})
        end
      end
    end
    
    def compile_hammer_file
      text = nil
      Hammer::Parser.for_extension(@hammer_file.extension).each do |parser|
        text ||= @hammer_file.raw_text
        parser = parser.new(:hammer_project => @hammer_project, :hammer_file => @hammer_file, :text => text)
        text = parser.parse()
        @hammer_file.compiled = true
      end
      @hammer_file.output_filename = Hammer::Utils.output_filename_for(@hammer_file.filename)
      @hammer_file.compiled_text = text
    end
    
    def after_compile
      return unless @production
      return unless @hammer_file.is_a_compiled_file
      
      filename = @hammer_file.output_filename
      extension = File.extname(filename)[1..-1]
      compilers = Hammer.after_compilers[extension] || []
      
      compilers.each do |postcompiler|
        @hammer_file.compiled_text = postcompiler.new(@hammer_file.compiled_text).parse()
      end
    end
  end
end