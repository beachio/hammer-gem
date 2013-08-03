class Hammer
  class Build
    attr_accessor :cache_directory, :project_directory, :output_directory,
                  :optimize_assets

    def initialize(options)
      @cache_directory   = options.fetch(:cache_directory)
      @project_directory = options.fetch(:project_directory)
      @output_directory  = options.fetch(:output_directory) ||
                             default_output_directory
      @optimize_assets   = options.fetch(:optimize_assets)
    end

    def hammer_time!(&complete)
      compile_project
      complete.call project, app_template
    end

    def stop_hammer_time!(&complete)
      watch_parent
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      hammer_time!(&complete)
    end

    def default_output_directory
      File.join(project_directory, 'Build')
    end

    def compile_project
      return unless project_exists?
      project.input_directory  = project_directory
      project.cache_directory  = cache_directory
      project.output_directory = output_directory
      project.compile
      project.write
    rescue Object => e
      project.error = e
    end

    def project_exists?
      File.exists?(project_directory)
    end

    def project
      @project ||= Hammer::Project.new(optimize_assets)
    end

    def app_template
      Hammer::AppTemplate.new(project)
    end

    def watch_parent
      Thread.new do
        while true
          exit if Process.ppid == 1
          sleep 1
        end
      end
    end
  end
end
