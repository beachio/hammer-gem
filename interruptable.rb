# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require 'hammer/build'

# Pause to prevent the UI from returning too quickly and wreaking havoc with
# FSEvents.
def not_too_fast(start, minimum_duration = 0.5)
  duration = Time.now - start
  sleep minimum_duration - duration if duration < minimum_duration
end

build = Hammer::Build.new(:cache_directory   => ARGV[0],
                          :project_directory => ARGV[1],
                          :output_directory  => ARGV[2],
                          :optimized   => ARGV.include?('PRODUCTION'))

start = Time.now
build.stop_hammer_time! do |project, app_template|
  not_too_fast(start)

  puts app_template
  exit app_template.success? ? 0 : 1
end
