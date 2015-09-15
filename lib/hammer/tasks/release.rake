def sh_with_clean_env(*args)
  puts "$: #{args.join(' ')}"
  if defined?(Bundler)
    Bundler.with_clean_env { sh *args }
  else
    sh *args
  end
end

def s3_config
  require "yaml"
  YAML.load_file('s3.yml')
end

def version
  open("VERSION").read.strip
end

def gem_files
  `git ls-files -z`.split("\0") +
    Dir['vendor/production/bundle/bundler/**/*'] +
    Dir['vendor/production/bundle/ruby/*/gems/**/*'] +
    Dir['vendor/production/bundle/ruby/*/bundler/gems/**/*']
end

desc "Release a gem!"
task :release => [ :test, :check_hammer_app_access, :pause_for_confirmation,
                   :bump_version, :test_local, :tag_release, :upload_gem,
                   :test_release, :deploy ] do
  puts "Done! We're now live on #{version}. Go test it."
end

desc "Bump the version by 0.0.1"
task :bump_version do
  current_version = open("VERSION").read
  new_version = current_version.split(".").join("")
  new_version = (new_version.to_i + 1).to_s
  new_version = new_version.split("").join(".")
  puts "Bumping from #{current_version} to #{new_version}"
  File.open("VERSION", 'w') do |f|
    f.write new_version
  end
end

desc 'Create and push a new tag to origin for this version'
task :tag_release => :bump_version do
  sh 'git', 'commit', '-a', '-m', "Release #{version}"
  sh 'git', 'tag', "v#{version}"
  sh 'git', 'push', 'origin'
  sh 'git', 'push', 'origin', "v#{version}"
end

task :check_hammer_app_access do
  puts "Checking for Hammer app access..."
  sh_with_clean_env 'heroku', 'config:get', 'LATEST_GEM_VERSION',
                    '--app', 'hammerformac'
end

desc 'Update vendored bundle'
task :bundle do
  puts 'Updating bundle...'
  Rake::FileUtilsExt.verbose false do

    # sh_with_clean_env "git checkout .bundle/config"

    # puts "Deleting existing files in vendor/production/bundle/ruby/* ..."
    # sh_with_clean_env *%w(rm -rf vendor/production/bundle/ruby/*)

    puts "Deleting cache ..."
    rm_rf [ 'vendor/production/cache', 'vendor/cache' ]
    # we can delete 'vendor/cache', if we want to re-download

    # puts "Runnning bundle cache..."
    sh_with_clean_env 'bundle cache'

    puts "bundle install..."

                          # --quiet
    sh_with_clean_env *%w(bundle install
                          --path=vendor/production/bundle
                          --local
                          --standalone
                          --without=development)

    sh_with_clean_env *%w(git checkout .bundle/config)

    Dir.chdir('vendor/production/bundle/ruby') do
      if File.exists?("2.0.0")
        sh_with_clean_env *%w(ln -s 2.0.0/ 1.8)
      else
        sh_with_clean_env *%w(ln -s 1.8/ 2.0.0)
      end
    end
  end
end

desc 'Package code and all dependencies'
file "dist/Gem.zip" => [:bundle] + gem_files do |t|
  require 'open3'

  puts 'Creating dist/Gem.zip... '
  Rake::FileUtilsExt.verbose false do
    command = %W(zip #{t.name}
                 --symlinks
                 --quiet
                 --latest-time
                 --recurse-paths
                 -@)
    Open3.popen3(*command) {|stdin, stdout, stderr|
      stdin.puts t.prerequisites
      stdin.close
      out = stdout.read.strip
      err = stderr.read.strip
      puts "  ** zip output: #{out}" unless out.empty?
      puts "  ** zip error: #{err}"  unless err.empty?
    }
  end
end

task :pause_for_confirmation do
  puts "Ready to upload! Cancel this task now if you're not ready! <3"
  sleep 2
end

task :upload_gem => 'dist/Gem.zip' do
  puts "Uploading to '#{s3_config['bucket']}'..."

  require 'aws/s3'
  AWS::S3::Base.establish_connection!(
    :access_key_id     => s3_config['access_key_id'],
    :secret_access_key => s3_config['secret_access_key']
  )

  AWS::S3::S3Object.store(
    'dist/Gem.zip',
    File.open('dist/Gem.zip'),
    s3_config['bucket'],
    :content_type => "application/zip",
    :access => :public_read
  )

  puts "Uploaded!"
end

def extract_and_test
  puts "Extracting and testing gem..."
  sh 'unzip', '-q', 'dist/Gem.zip'
  sh 'ruby', '-I', 'test:lib', './test/tests.rb'
end

desc 'Extract local bundle and run tests'
task :test_local => 'dist/Gem.zip' do
  require "tmpdir"
  Rake::FileUtilsExt.verbose false do
    Dir.mktmpdir "testing-build" do |dir|
      sh 'cp', 'dist/Gem.zip', dir
      Dir.chdir(dir) do
        extract_and_test
      end
    end
  end
end

desc "Test the released version of the Hammer compiler"
task :test_release do
  require "tmpdir"
  require "zlib"
  require "open-uri"

  Rake::FileUtilsExt.verbose false do
    Dir.mktmpdir "testing-build" do |dir|
      Dir.chdir(dir) do
        puts "Downloading gem..."
        sh 'wget', 'http://hammer-updates.s3.amazonaws.com/Gem.zip'
        extract_and_test
      end
    end
  end
end

task :deploy do
  sh_with_clean_env 'heroku', 'config:set', "LATEST_GEM_VERSION=#{version}",
                    '--app', 'hammerformac'
end

task :install => 'dist/Gem.zip' do
  [
    '~/Library/Containers/com.riot.hammer/Data/Library/Application\\ Support/Riot/Hammer/Gem',
    '~/Library/Application\\ Support/Riot/Hammer/Gem
  '].each do |directory|
    sh_with_clean_env 'rm', '-rf', directory
    sh_with_clean_env 'mkdir', '-p', directory
    sh_with_clean_env 'unzip', 'dist/Gem.zip', '-d', directory
  end
end
