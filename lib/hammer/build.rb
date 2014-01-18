require 'hammer/templates/application'

module Hammer
  class Build

    attr_accessor :cache_directory, :project_directory, :output_directory, 
                  :optimized, :project, :success

    def initialize(options)
      @project = Project.new(options)
    end

    def compile(callback=nil)
      @project.read()
      @project.compile()
      @project.write()
      @success = !@project.error
    end

    def hammer_time!(&complete)
      compile()
      app_template = Hammer::ApplicationTemplate.new(:project => @project)
      complete.call project, app_template
    end

    def default_output_directory
      File.join(@input_directory, 'Build')
    end

    def wait(&complete)
      protect_against_zombies
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      hammer_time!(&complete)
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