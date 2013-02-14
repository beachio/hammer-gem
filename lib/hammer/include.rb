module Templatey
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

class Object
  def try(method)
    send method if respond_to? method
  end
end

$FILE_PATH = File.expand_path(File.dirname(File.dirname(__FILE__)))
$LOAD_PATH << File.join(File.dirname(File.expand_path(__FILE__)), "lib")
$LOAD_PATH << File.join(File.dirname(File.expand_path(__FILE__)), "..")

## Let's start by $LOAD_PATHing all the directories inside vendor/gems/*/lib
# ["../vendor/gems/*"].each do |directory|

dir = File.join(File.dirname(__FILE__), "../../vendor/gems/*")
Dir.glob(dir).each do |dir|
  d = File.directory?(lib = "#{dir}/lib") ? lib : dir
  $LOAD_PATH << d
end

require File.join(File.dirname(__FILE__), "hammer")

["hammer", "parsers", "hammer_file", "hammer_project", "hammer_error"].each do |file|
  require File.join(File.dirname(__FILE__), file)
end

["templates/*.rb", "parsers/*.rb"].each do |path|
  Dir[File.join(File.dirname(__FILE__), path)].each do |file| 
    require file 
  end
end

$LOAD_PATH << File.dirname(__FILE__)

## Now require all the gems we need
require 'json'
require 'fileutils'
require 'sass'
require 'plist'
require 'execjs'
require 'coffee-script'
require 'cgi'
require 'bourbon'
require 'kramdown'
require 'shellwords'
require 'haml'
require 'timeout'
require 'amp'
require 'uglifier'