class Thing
  attr_accessor :temporary_directory, :project_directory, :output_directory,
                :no_project_process

  def initialize(options)
    @temporary_directory = options.fetch(:temporary_directory)
    @project_directory   = options.fetch(:project_directory)
    @output_directory    = options.fetch(:output_directory) ||
                             default_output_directory
  end

  def default_output_directory
    File.join(project_directory, 'Build')
  end

  def hammer_time!
    compile_project
    write_template
  end

  def no_project(&no_project_process)
    @no_project_process = no_project_process
  end

  def compile_project
    unless project_exists?
      no_project_process.call if no_project_process
      return
    end

    project.input_directory     = project_directory
    project.temporary_directory = temporary_directory
    project.output_directory    = output_directory
    project.compile
    project.write
  end

  def write_template
    puts template
    exit template.success? ? 0 : 1
  end

  def project_exists?
    File.exists?(project_directory)
  end

  def production?
    input.include?('PRODUCTION')
  end

  def project
    @project ||= Hammer::Project.new(production?)
  end

  def template
    @template ||= Hammer::AppTemplate.new(project)
  end
end
