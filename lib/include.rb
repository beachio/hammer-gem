class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end


$FILE_PATH = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(File.dirname(File.expand_path(__FILE__)), "lib")

## Let's start by $LOAD_PATHing all the directories inside vendor/gems/*/lib
["vendor/gems/*"].each do |directory|
  Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), directory)).each do |dir|
    d = File.directory?(lib = "#{dir}/lib") ? lib : dir
    $LOAD_PATH << d
  end
end

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