require "./hammer"
require "./parsers"
require "./hammer_file"

Dir['./lib/parsers/*', './lib/templates/*'].each do |file|
  require file
end

temporary_directory = ARGV[0]
project_directory = ARGV[1]
output_directory = ARGV[2] || File.join(project_directory, "Build")

# Clear the final product out
FileUtils.rm_rf(output_directory)

project = Hammer::Project.new()
project.create_hammer_files_from_directory(project_directory)

hammer_files = project.compile()

hammer_files.each do |hammer_file|
  
  if File.basename(hammer_file.filename).split("")[0] != "_"
    
    sub_directory   = File.dirname(hammer_file.output_filename)
    final_location  = File.join output_directory, sub_directory
    FileUtils.mkdir_p(final_location)
    
    output_path = File.join(output_directory, hammer_file.output_filename)
    
    f = File.new(output_path, "w")
    f.write(hammer_file.compiled_text)
    f.close
    
  end
end

template = Hammer::AppTemplate.new(hammer_files)
puts template

