# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")

temporary_directory = ARGV[0]
project_directory = ARGV[1]
output_directory = ARGV[2] || File.join(project_directory, "Build")

@production = ARGV.include?('PRODUCTION')

@errors = 0

hammer_files = nil

# Make sure we aren't a zombie!
Thread.new do
  while true
    exit if Process.ppid == 1
    sleep 1
  end
end

begin
  while true
    sleep 0.1
  end    
rescue SystemExit, Interrupt
  project = Hammer::Project.new(@production)

  if File.exists? project_directory
    project.input_directory     = project_directory
    project.temporary_directory = temporary_directory
    project.output_directory    = output_directory
    project.compile()
    project.write()  
  else
    # No files to process. Pause to prevent the UI from returning too quickly
    # and wreaking havoc with FSEvents.
    sleep 0.5
  end
  
  unless ARGV.include? "DEBUG"
    template = Hammer::AppTemplate.new(project)
    puts template
    exit template.success? ? 0 : 1
  end
end
