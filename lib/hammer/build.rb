module Hammer
  class Build

    attr_accessor :cache_directory, :project_directory, :output_directory, 
                  :optimized, :project

    def initialize(options)
      @project = Project.new(options)
    end

    def compile
      @project.read()
      @project.compile()
      @project.write()
    end

    def default_output_directory
      File.join(@input_directory, 'Build')
    end

    def wait(&complete)
      protect_against_zombies
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      compile(&complete)
    end

    # This process kills the build if this process's parent process exits.
    def protect_against_zombies
      Thread.new do
        while true
          exit if Process.ppid == 1
          sleep 1
        end
      end
    end
  end
end