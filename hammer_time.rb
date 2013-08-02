# encoding: utf-8
$LANG = "UTF-8"

require File.join(File.dirname(__FILE__), "lib/hammer/hammer")
require File.join(File.dirname(__FILE__), "lib/hammer/thing")

Thing.new.hammer_time!
