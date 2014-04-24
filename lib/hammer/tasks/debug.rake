task :use do
  require 'pathname'
  require 'fileutils'

  dev_path = Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "..")).expand_path
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem").expand_path

  puts "Deleting existing gem at #{hammer_path}..."
  FileUtils.rm_rf hammer_path
  puts "Copying #{dev_path} to #{hammer_path}..."
  FileUtils.cp_r dev_path, hammer_path

  puts "opening Hammer..."
  puts `open -a Hammer.app`
end