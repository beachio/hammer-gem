# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")

temporary_directory = ARGV[0]
project_directory = ARGV[1]
output_directory = ARGV[2] || File.join(project_directory, "Build")

@production = ARGV.include?('PRODUCTION')

@errors = 0

hammer_files = nil
if File.exists? project_directory
  project = Hammer::Project.new(@production)
  project.input_directory = project_directory
  project.temporary_directory = temporary_directory
  project.output_directory = output_directory
  project.compile()
  project.write()  
end

unless ARGV.include? "DEBUG"
  template = Hammer::AppTemplate.new(project)
  puts template
  exit template.success? ? 0 : 1
end
