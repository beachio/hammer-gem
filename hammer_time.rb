require File.join(File.dirname(__FILE__), "lib/hammer/hammer")

temporary_directory = ARGV[0]
project_directory = ARGV[1]
output_directory = ARGV[2] || File.join(project_directory, "Build")

@production = ARGV.include?('PRODUCTION')

@errors = 0

hammer_files = nil
if File.exists? project_directory
  
  project = Hammer::Project.new(@production)
  
  project.create_hammer_files_from_directory(project_directory, output_directory)
  hammer_files = project.compile() 
    
  # Clear the final product out
  FileUtils.rm_rf(output_directory)
  hammer_files.each do |hammer_file|
    
    if !File.basename(hammer_file.filename).start_with?("_")
      
      sub_directory   = File.dirname(hammer_file.output_filename)
      final_location  = File.join output_directory, sub_directory
      
      FileUtils.mkdir_p(final_location)
      
      output_path = File.join(output_directory, hammer_file.output_filename)
      hammer_file.output_path = output_path
      
      @errors += 1 if hammer_file.error

      f = File.new(output_path, "w")
      f.write(hammer_file.compiled_text)
      f.close
    end
  end
end

template = Hammer::AppTemplate.new(hammer_files)

puts template

exit template.success? ? 0 : 1