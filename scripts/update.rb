#! /usr/bin/ruby

repo_url = 'https://github.com/RiotHQ/hammer-gem.git'
tmp_directory = "/tmp/hammer-gem-#{Time.now.to_i}"

check_bundler = 'which bundle'
check_git = 'which git'
make_tmp_directory = "mkdir #{tmp_directory}"
go_to_tmp_directory = "cd #{tmp_directory}"
clone_repository = "git clone #{repo_url}"
go_to_gem_root = 'cd hammer-gem'
checkout_beta_branch = defined?(branch) ? "git checkout #{branch}" : 'git checkout latest'
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
          go_to_gem_root,
          install_gem
         ].join(' && ')
  version = File.open("#{tmp_directory}/hammer-gem/VERSION").read
else
  puts 'Error during gem install. Please fix errors and try again.'
end

system clean_up