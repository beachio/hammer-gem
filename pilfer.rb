# encoding: utf-8

require "pilfer"

reporter = Pilfer::Server.new('http://localhost:3000', 'kw0P4-rQe0YUhmH3wYJ2Uw')
# reporter = Pilfer::Logger.new($stdout)
profiler = Pilfer::Profiler.new(reporter)
profiler.profile('Hammer') do

  $LANG = "UTF-8"

  require File.join(File.dirname(__FILE__), "lib/hammer")

  cache_directory = Dir.mktmpdir
  output_directory = Dir.mktmpdir

  @optimized = ARGV.include?('PRODUCTION')

  @errors = 0

  directories = Dir["test/hammer/functional/*"]
  directories.each do |project_directory|
    hammer_files = nil
    project = Hammer::Project.new(input_directory: project_directory)
    # if File.exists? project_directory
      # project.cacher.clear()
      # project.input_directory = project_directory
      # project.cache_directory = cache_directory
      # project.output_directory = output_directory
      project.compile()
      project.write()
    # end

    # unless ARGV.include? "DEBUG"
    #   template = Hammer::AppTemplate.new(project)
    #   puts template
    #   exit template.success? ? 0 : 1
    # end
  end

end