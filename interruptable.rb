# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require File.join(File.dirname(__FILE__), "lib/hammer/thing")

def watch_parent
  Thread.new do
    while true
      exit if Process.ppid == 1
      sleep 1
    end
  end
end

def compile_project_when_interrupted
  sleep 0.1 while true
rescue SystemExit, Interrupt
  thing = Thing.new
  thing.no_project do
    # No files to process. Pause to prevent the UI from returning too quickly
    # and wreaking havoc with FSEvents.
    sleep 0.5
  end
  thing.hammer_time!
end

watch_parent
compile_project_when_interrupted
