class Thing
  attr_accessor :input, :no_project_process

  def initialize(input = ARGV)
    @input = input
  end

  def hammer_time!
    compile_project
    write_template
  end

  def no_project(&no_project_process)
    self.no_project_process = no_project_process
  end

  def compile_project
    unless project_exists?
      no_project_process.call
      return
    end

    project.input_directory     = project_directory
    project.temporary_directory = temporary_directory
    project.output_directory    = output_directory
    project.compile
    project.write
  end

  def write_template
    return if debug?
    puts template
    exit template.success? ? 0 : 1
  end

  def temporary_directory
    input[0]
  end

  def project_directory
    input[1]
  end

  def output_directory
    input[2] || File.join(project_directory, 'Build')
  end

  def project_exists?
    File.exists?(project_directory)
  end

  def production?
    input.include?('PRODUCTION')
  end

  def debug?
    ARGV.include?('DEBUG')
  end

  def project
    @project ||= Hammer::Project.new(production?)
  end

  def template
    @template ||= Hammer::AppTemplate.new(project)
  end
end
