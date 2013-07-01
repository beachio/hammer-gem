# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require "tmpdir"

@production = ARGV.include?('PRODUCTION')
@errors = 0

# Make sure we aren't a zombie!
Thread.new do
  while true
    exit if Process.ppid == 1
    sleep 1
  end
end

project = Hammer::Project.new(@production)
project.input_directory = ARGV[0]
project.temporary_directory = Dir.tmpdir
project.output_directory = File.join(project.input_directory, "Build")

puts "Starting compilation..."
puts "Temporary directory: #{project.temporary_directory}"

t = Time.now
project.compile()
p "Compile time: #{Time.now - t} seconds"

t = Time.now
project.write()
p "Write time: #{Time.now - t} seconds"
@errors = project.errors

project.hammer_files.each do |hammer_file|
  if hammer_file.error
    puts "Error in #{hammer_file.filename}:"
    puts " - #{hammer_file.error.text}"
  end
end
