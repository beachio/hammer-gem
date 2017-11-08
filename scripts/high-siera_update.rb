require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'open3'

def update_hammer(main_path)
  repo_url = 'https://github.com/RiotHQ/hammer-gem.git'
  tmp_directory = "/tmp/hammer-gem-#{Time.now.to_i}"

  check_bundler = 'which bundle'
  check_git = 'which git'
  make_tmp_directory = "mkdir #{tmp_directory}"
  go_to_tmp_directory = "cd #{tmp_directory}"
  clone_repository = "git clone #{repo_url}"
  go_to_gem_root = 'cd hammer-gem'
  checkout_beta_branch = 'git checkout merged_latest_chisel'
  install_dependencies = 'bundle install --jobs 4 && rake bundle'
  install_gem = 'bundle exec rake use'
  clean_up = "rm -rf #{tmp_directory}"

  puts "Check requirements..."
  unless system(check_bundler)
    puts 'Bundler is not installed. You can install bundler using command:
  "sudo gem install bundler"'
    abort
  end
  unless system(check_git)
    puts 'Git is not installed. You can install git using command:
  "brew install git"'
    abort
  end

  puts "All is ok, lets rock it!"

  preparation_result = system [
                                  make_tmp_directory,
                                  go_to_tmp_directory,
                                  clone_repository,
                                  go_to_gem_root,
                                  checkout_beta_branch,
                                  install_dependencies
                              ].join(' && ')
  if preparation_result
    system [
               go_to_tmp_directory,
               go_to_gem_root
           ].join(' && ')
    copy_to_hammer_app(tmp_directory, main_path)
    version = File.open("#{tmp_directory}/hammer-gem/VERSION").read
  else
    puts 'Error during gem install. Please fix errors and try again.'
  end

  system clean_up
end

def copy_to_hammer_app(dev_path, hammer_path)

  dev_path += "/hammer-gem/"
  hammer_path += "Contents/Resources/Gem/"
  FileUtils.mkdir_p(hammer_path)

  puts "Installing this version of Hammer into your Hammer executable!"
  puts "Copying #{dev_path} to #{hammer_path}"

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

def script_start(path)
  if path[-1] != '/'
    path += '/'
  end
  unless Dir["#{path}*"].empty?
    if Dir["#{path}*"][0] != "#{path}Contents"
      p "Path that you indicate is wrong please indicate right path"
    else
      update_hammer(path)
    end
  else
    p "Path that you indicate is wrong please indicate right path"
  end
end

unless ARGV.empty?
  path = ARGV[0]
  script_start(path)
else
  unless path.nil?
    script_start(path)
  end
end

