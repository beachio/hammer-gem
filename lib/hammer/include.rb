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

require 'pathname'

root = Pathname.new(__FILE__).expand_path + '..' + '..' + '..'
$LOAD_PATH.unshift root
$LOAD_PATH.unshift root + 'lib'

# Development gems take precedence
$LOAD_PATH.unshift root + 'vendor' + 'production' + 'bundle'
$LOAD_PATH.unshift root + 'vendor' + 'bundle'

require 'bundler/setup'
require 'hammer/parsers'
require 'hammer/compressor'
require 'hammer/hammer_file'
require 'hammer/hammer_project'
require 'hammer/hammer_error'
require 'hammer/cacher'

%w(templates parsers compressors).each do |type|
  Pathname.glob(File.join(root, 'lib', 'hammer', type, '*')).each do |file|
    path = file.expand_path.relative_path_from(root + 'lib').dirname
    file_name = file.basename(file.extname)
    require path + file_name
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

require 'eco'
require 'ejs'
