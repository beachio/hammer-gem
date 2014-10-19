require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'open3'

desc "Compile the gem into Hammer's Application Support directory"
task :use do

  dev_path = Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "..")).expand_path.to_s+"/"
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem/").expand_path.to_s+"/"
  FileUtils.mkdir_p(hammer_path)

  puts "Installing this version of Hammer into your Hammer executable!"
  puts "Copying #{dev_path} to #{hammer_path}"

  print_command "rsync -az --delete --exclude=\".sass-cache\" \
                 --exclude=\"dist/\" --exclude=\"coverage\" \
                 --exclude=\".git/\" \"#{dev_path}\" \"#{hammer_path}\""

  hammer_path = Pathname.new("~/Library/Application Support/Riot/Hammer/Gem").expand_path.to_s+"/"

  print_command "rsync -az --delete --exclude=\".sass-cache\" \
                 --exclude=\"dist/\" --exclude=\"coverage\" \
                 --exclude=\".git/\" \"#{dev_path}\" \"#{hammer_path}\""

  version = "#{File.open(File.join(dev_path, 'VERSION')).read()}"
  puts "Success. Hammer is now running #{version}"
end

def print_command(command)
  Open3.popen3(command) do |stdin, stdout, stderr, wait_thread|
    if ((stdout_read = stdout.read).length > 0)
      puts stdout_read
    end
    if ((sterr_read = stderr.read).length > 0)
      puts sterr_read
    end
  end
end

task :revert do
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem/").expand_path.to_s+"/"
  FileUtils.rm_rf(hammer_path)
end