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
  project.temporary_directory = temporary_directory
  
  project.create_hammer_files_from_directory(project_directory, output_directory)
  project.output_directory = output_directory
  hammer_files = project.compile() 
    
  # Clear the final product out
  # TODO: Put this back in the Ruby if we ever release this as a gem.
  # Hammer currently expects an empty directory, I suppose.
  # FileUtils.rm_rf(output_directory)

  project.write()  
  @errors = project.errors
end

unless ARGV.include? "DEBUG"
  template = Hammer::AppTemplate.new(hammer_files, project)
  puts template
  exit template.success? ? 0 : 1
end
