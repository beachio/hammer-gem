# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require "tmpdir"

@project = Hammer::Project.new
@project.input_directory = "/Users/elliott/Desktop/a"
@project.output_directory = File.join(@project.input_directory, "Build")
@project.temporary_directory = Dir.tmpdir
@project.hammer_files()