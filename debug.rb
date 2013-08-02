# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require File.join(File.dirname(__FILE__), "lib/hammer/build")

class Hammer::DebugBuild < Hammer::Build
  def project
    @project ||= Hammer::DebugProject.new(optimize_assets)
  end
end

class Hammer::DebugProject < Hammer::Project
  def time(label)
    t = Time.now
    value = yield
    puts "#{label} time: #{Time.now - t} seconds"
    value
  end

  def compile
    time('Compile') { super }
  end

  def write
    time('Write') { super }
  end
end

cache_directory   = ARGV[0]
project_directory = ARGV[1]
output_directory  = ARGV[2]

# If only one argument is given, use it as the project directory.
if project_directory.nil?
  project_directory = cache_directory
  cache_directory = Dir.tmpdir
end

build = Hammer::DebugBuild.new(:cache_directory   => cache_directory,
                               :project_directory => project_directory,
                               :output_directory  => output_directory,
                               :optimize_assets   => ARGV.include?('PRODUCTION'))

puts "Starting compilation..."
puts "Cache directory: #{build.cache_directory}"

build.hammer_time! do |project, app_template|
  project.hammer_files.each do |hammer_file|
    next unless hammer_file.error
    puts "Error in #{hammer_file.filename}:"
    puts " - #{hammer_file.error.text}"
  end

  exit app_template.success? ? 0 : 1
end
