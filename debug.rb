# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require "tmpdir"

temporary_directory = Dir.tmpdir
project_directory = ARGV[0]
output_directory = File.join(project_directory, "Build")

@production = ARGV.include?('PRODUCTION')
@errors = 0

# Make sure we aren't a zombie!
Thread.new do
  while true
    exit if Process.ppid == 1
    sleep 1
  end
end

def p(text)
  puts text
end

project = Hammer::Project.new(@production)
project.input_directory = project_directory
project.temporary_directory = temporary_directory
project.output_directory = output_directory
project.compile()

project.write()  
@errors = project.errors

puts "Temporary directory: #{temporary_directory}"

project.hammer_files.each do |hammer_file|
  if !hammer_file.from_cache && hammer_file.compiled_text
    puts hammer_file.filename
  end
end