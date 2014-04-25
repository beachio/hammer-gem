task :use do
  require 'pathname'
  require 'fileutils'
  require 'tmpdir'

  dev_path = Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "..")).expand_path
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem").expand_path

  puts "Deleting existing gem at #{hammer_path}..."
  # FileUtils.rm_rf hammer_path
  new_hammer_path = Dir.mktmpdir()
  FileUtils.mv hammer_path, new_hammer_path

  puts "Copying #{dev_path} to #{hammer_path}..."
  # FileUtils.cp_r dev_path, hammer_path
  args = ['rsync', '-avz', dev_path, hammer_path]

  Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
    output = stdout.read
    error = stderr.read
  end

  puts output

  puts "opening Hammer..."
  puts `open -a Hammer.app`

  puts "Deleting the old version..."
  FileUtils.rm_rf new_hammer_path
end