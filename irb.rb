# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require "tmpdir"

require 'rubygems'
require 'ruby-debug'

def prompt(*args)
  print(*args)
  gets
end

@project_directory = ARGV[0]

def p
  @project
end

def load_project()
  project_directory   = @project_directory
  production          = ARGV.include? "PRODUCTION"
  temporary_directory = Dir.tmpdir
  output_directory    = File.join(project_directory, "Build")

  print "Creating #{production ? "production " : ""}Hammer project (@project)..."
  @project = Hammer::Project.new(production)
  @project.temporary_directory = temporary_directory
  @project.create_hammer_files_from_directory(project_directory, output_directory)
  puts " done."
  
  @project.compile()

  # @project.hammer_files.each do |file|
  #   if file.error
  #     puts "Error in #{file.filename} on line #{file.error.line_number}: #{file.error.text}"
  #   end
  # end
end

def reload!
  @reload = true
  exit
end

def f(filename)
  @project.find_file(filename)
end

require 'irb'
module IRB # :nodoc:
  def self.start_session(binding)
    unless @__initialized
      args = ARGV
      ARGV.replace(ARGV.dup)
      IRB.setup(nil)
      ARGV.replace(args)
      @__initialized = true
    end

    workspace = WorkSpace.new(binding)

    irb = Irb.new(workspace)

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

@first = true
while true do

  # First time through
  if @reload != false
    # puts "reloading!"
    @reload = false
    @first = false
  else
    break
  end

  # puts "starting.."
  load_project()
  IRB.start_session(binding)
  catch (:IRB_EXIT) do
    # puts "Reloading: #{@reloading}"
  end
end