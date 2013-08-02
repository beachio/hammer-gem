# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require File.join(File.dirname(__FILE__), "lib/hammer/thing")

Thing.new(:temporary_directory => ARGV[0],
          :project_directory   => ARGV[1],
          :output_directory    => ARGV[2]).hammer_time!
