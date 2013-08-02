# encoding: utf-8

require "pilfer"

reporter = Pilfer::Server.new('http://pilfer-server.dev', 'qftUqsPYioyF7swYpGv4CA')
# reporter = Pilfer::Logger.new($stdout)
profiler = Pilfer::Profiler.new(reporter)
profiler.profile('Hammer') do

  $LANG = "UTF-8"

  require File.join(File.dirname(__FILE__), "lib/hammer/hammer")

  cache_directory = ARGV[0]
  project_directory = ARGV[1]
  output_directory = ARGV[2] || File.join(project_directory, "Build")

  @production = ARGV.include?('PRODUCTION')

  @errors = 0

  hammer_files = nil
  project = Hammer::Project.new(@production)
  if File.exists? project_directory
    project.cacher.clear()
    project.input_directory = project_directory
    project.cache_directory = cache_directory
    project.output_directory = output_directory
    project.compile()
    project.write()
  end

  unless ARGV.include? "DEBUG"
    template = Hammer::AppTemplate.new(project)
    puts template
    exit template.success? ? 0 : 1
  end

end