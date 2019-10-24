require 'pathname'
require 'fileutils'
require 'tmpdir'
require 'open3'

def update_hammer(main_path, branch)
  repo_url = 'https://github.com/RiotHQ/hammer-gem.git'
  tmp_directory = "/tmp/hammer-gem-#{Time.now.to_i}"
  ruby_for_catalina = %x[ruby -v].match?('2.6.3')
  check_bundler = 'which bundle'
  check_git = 'which git'
  make_tmp_directory = "mkdir #{tmp_directory}"
  go_to_tmp_directory = "cd #{tmp_directory}"
  clone_repository = "git clone #{repo_url}"
  go_to_gem_root = 'cd hammer-gem'
  checkout_beta_branch = branch.nil? ? 'git checkout latest' :  "git checkout #{branch}"
  install_dependencies = 'bundle install --jobs 4 && rake bundle'
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
                              ].join(' && ')
  if preparation_result
    add_fix_for_catalina(tmp_directory,go_to_tmp_directory,go_to_gem_root) if ruby_for_catalina
    if system [
               go_to_tmp_directory,
               go_to_gem_root,
               install_dependencies
              ].join(' && ')
      copy_to_hammer_app(tmp_directory, main_path)
    version = File.open("#{tmp_directory}/hammer-gem/VERSION").read
    else
      puts 'Error during gem install. Please fix errors and try again.'
    end
  else
    puts 'Error git repository install. Please fix errors and try again.'
  end
  system clean_up
end

def add_fix_for_catalina(tmp_directory,tmp,hammer)
  remove_gem_lock = "rm Gemfile.lock"
  add_json = "gem 'json', '2.2.0'"
  path_to_cache = "lib/hammer/parsers"
  sys_array = [tmp, hammer]
  unless File.open("#{tmp_directory}/hammer-gem/Gemfile",'r').read.match?(add_json)
    sys_array << "echo 'gem \"json\", \"2.2.0\"' >> Gemfile"
    sys_array << remove_gem_lock
  end
  File.open("#{tmp_directory}/hammer-gem/lib/hammer/parsers/cache-path",'w') do |f|
    f.puts("~/.hammer-gem")
    f.close
    end
  system sys_array.join(" && ")
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
unless ARGV.empty?
  path = ARGV[0]
  branch = ARGV[1]
end
unless path.nil?
  if path[-1] != '/'
    path += '/'
  end
  unless Dir["#{path}*"].empty?
    if Dir["#{path}*"][0] != "#{path}Contents"
      p "Path that you indicate is wrong please indicate right path"
    else
      branch = defined?(branch) ? branch :  nil
      update_hammer(path, branch)
    end
  else
    p "Path that you indicate is wrong please indicate right path"
  end
else
  p 'Please indicate full path to Hammer.app'
end




