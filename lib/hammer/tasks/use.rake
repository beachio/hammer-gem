require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'open3'

task :use do

  dev_path = Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "..")).expand_path.to_s+"/"
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem/").expand_path.to_s+"/"
  FileUtils.mkdir_p(hammer_path)

  puts "Installing this version of Hammer into your Hammer executable!"
  puts "Copying #{dev_path} to #{hammer_path}"

  Open3.popen3("rsync -az --delete --exclude=\".sass-cache\" --exclude=\"dist/\" --exclude=\"coverage\" --exclude=\".git/\" \"#{dev_path}\" \"#{hammer_path}\"") do |stdin, stdout, stderr, wait_thread|
    if ((stdout_read = stdout.read).length > 0)
      puts stdout_read
    end
    if ((sterr_read = stderr.read).length > 0)
      puts sterr_read
    end
  end

  version = "#{File.open(File.join(dev_path, 'VERSION')).read()}"
  puts "Success. Hammer is now running #{version}"
end

task :revert do
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem/").expand_path.to_s+"/"
  FileUtils.rm_rf(hammer_path)
end