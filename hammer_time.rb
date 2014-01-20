# encoding: utf-8
$LANG = "UTF-8"

# Catch interrupts received before app is loaded.
interrupted = false
trap('INT') { interrupted = true }

require File.join(File.dirname(__FILE__), "lib/hammer")
require 'hammer/build'

# Pause to prevent the UI from returning too quickly and wreaking havoc with
# FSEvents.
def not_too_fast(start, minimum_duration = 0.5)
  duration = Time.now - start
  sleep minimum_duration - duration if duration < minimum_duration
end

if ARGV.length == 1
  build = Hammer::Build.new(:input_directory => ARGV[0], :optimized   => ARGV.include?('PRODUCTION'))
else
  build = Hammer::Build.new(:cache_directory   => ARGV[0],
                            :input_directory => ARGV[1],
                            :output_directory  => ARGV[2],
                            :optimized   => ARGV.include?('PRODUCTION'))
end
start = Time.now

trap('INT', 'DEFAULT')

if ARGV.include?('PRELOAD') and !interrupted
  build.wait do |project, app_template|
    not_too_fast(start)
    puts app_template
    exit build.success ? 0 : 1
  end
else
  build.hammer_time! do |project, app_template|
    not_too_fast(start)
    puts app_template
    exit build.success ? 0 : 1
  end
end
