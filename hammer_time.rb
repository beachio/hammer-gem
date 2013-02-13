require "./hammer"
require "./parsers"
require "./hammer_file"

Dir['./lib/parsers/*', './lib/templates/*'].each do |file|
  require file
end

project = Hammer::Project.new()

FileUtils.rm_rf("/Users/elliott/Desktop/a/Build")

project.create_hammer_files_from_directory("/Users/elliott/Desktop/a")

hammer_files = project.compile()

output_directory = "/Users/elliott/Desktop/a/Build"

hammer_files.each do |hammer_file|
  FileUtils.mkdir_p(File.join(output_directory, File.dirname(hammer_file.filename)))
  
  if File.basename(hammer_file.filename).split("")[0] != "_"
    output_path = File.join(output_directory, hammer_file.output_filename)
    f = File.new(output_path, "w")
    f.write(hammer_file.compiled_text)
    f.close
  end
end

template = Hammer::AppTemplate.new(hammer_files)
puts template

