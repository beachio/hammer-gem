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
t = Time.now
project.compile()
p "Compile time: #{Time.now - t} seconds"
t = Time.now
project.write()
p "Write time: #{Time.now - t} seconds"
@errors = project.errors

puts "Temporary directory: #{temporary_directory}"