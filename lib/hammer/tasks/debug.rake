task :use do
  require 'pathname'
  require 'fileutils'
  require 'tmpdir'
  require 'open3'

  dev_path = Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "..")).expand_path.to_s+"/"
  hammer_path = Pathname.new("~/Library/Containers/com.riot.hammer/Data/Library/Application Support/Riot/Hammer/Gem/").expand_path.to_s+"/"
  FileUtils.mkdir_p(hammer_path)

  puts "Installing this version of Hammer into your Hammer executable!"
  puts "Copying #{dev_path} to #{hammer_path}"

  Open3.popen3("rsync -az --delete --exclude=\".sass-cache\" --exclude=\"dist/\" --exclude=\".git/\" \"#{dev_path}\" \"#{hammer_path}\"") do |stdin, stdout, stderr, wait_thread|
    puts stdout.read
    puts stderr.read
  end

  puts "Done."
end