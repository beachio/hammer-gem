# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")

temporary_directory = ARGV[0]
project_directory = ARGV[1]
output_directory = ARGV[2] || File.join(project_directory, "Build")

@production = ARGV.include?('PRODUCTION')

@errors = 0

hammer_files = nil

begin
  while true
    sleep 0.1
  end    
rescue SystemExit, Interrupt
  project = Hammer::Project.new(@production)

  if File.exists? project_directory
    project.temporary_directory = temporary_directory
    project.create_hammer_files_from_directory(project_directory, output_directory)
    project.output_directory = output_directory
    hammer_files = project.compile() 
  else
    # Minimum sleep time. No files. 
    sleep 0.5
  end

  project.write()  
  @errors = project.errors
  
  unless ARGV.include? "DEBUG"
    template = Hammer::AppTemplate.new(hammer_files, project)
    puts template
    exit template.success? ? 0 : 1
  end
end
