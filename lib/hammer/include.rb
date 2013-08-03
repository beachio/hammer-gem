if RUBY_VERSION.to_f == 2.0
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

module Templatey
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

DEBUG = ARGV.include? "DEBUG"

if DEBUG
  def log(val)
    puts(val)
  end
else
  def log(val)
    #
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

["hammer", "parsers", "compressor", "hammer_file", "hammer_project", "hammer_error", "cacher"].each do |file|
  require File.join(File.dirname(__FILE__), file)
end

["templates/*.rb", "parsers/*.rb", "compressors/*"].each do |path|
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

require 'eco'
require 'ejs'