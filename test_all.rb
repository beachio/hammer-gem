# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require "tmpdir"
require "rubygems"
require "pry"

@production = ARGV.include?('PRODUCTION')
@pry = ARGV.include?('PRY')
@errors = false

paths = Dir.glob("/Users/elliott/Sites/hammer/Hammer\ Projects/*")
@longest = paths.max_by{|a| a.length}.length

paths.each do |path|
  project = Hammer::Project.new(@production)
  project.input_directory = path
  project.cache_directory = Dir.tmpdir
  project.output_directory = File.join(project.input_directory, "Build")
  
  FileUtils.rm_rf project.cache_directory
  FileUtils.rm_rf project.output_directory
  t = Time.now
  
  print "Compiling #{path}"
  
  project.compile()
  project.write()
  
  if project.errors.empty?
    print " " * (@longest - path.length)
    print " #{project.errors.length} errors. Total time: #{Time.now - t}"
  else
    project.errors.each do |error|
      puts "  Error in #{error.try(:hammer_file).try(:filename)}:"
      puts "    #{error.text}"
      binding.pry if @pry
    end
    @errors = true
  end
  
  puts
end

exit @errors ? 0 : 1