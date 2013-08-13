def s3_config
  YAML.load_file('s3.yml')
end

def version
  open("VERSION").read.strip
end

def gem_files
  `git ls-files -z`.split("\0") +
    Dir['vendor/production/bundle/bundler/**/*'] +
    Dir['vendor/production/bundle/**/gems/**/*']
end

desc "Release a gem!"
task :release => [ :test, :check_hammer_app_access, :bump_version,
                   :upload_gem, :test_release, :deploy ] do
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

task :check_hammer_app_access do
  puts "Checking for Hammer app access..."
  sh 'heroku', 'config:get', 'LATEST_GEM_VERSION', '--app', 'hammerformac'
end

task :bundle do
  puts 'Updating bundle...'
  Rake::FileUtilsExt.verbose false do
    rm_rf [ 'vendor/cache', 'vendor/production' ]

    # bundle-cache has no verbosity option
    sh 'bundle cache 1>/dev/null'

    sh *%w(bundle install
           --quiet
           --local
           --path=vendor/production/bundle
           --standalone
           --without development)
    sh *%w(git checkout .bundle/config)
  end
end

file "Gem.zip" => [:bundle] + gem_files do |t|
  puts 'Creating Gem.zip...'
  Rake::FileUtilsExt.verbose false do
    sh 'zip', t.name, '--quiet', '--latest-time', '--recurse-paths', *t.prerequisites
  end
end

task :upload_gem => 'Gem.zip' do
  require 'aws/s3'

  puts "Ready to upload! Cancel this task now if you're not ready! <3"
  sleep 2

  AWS.config(s3_config)
  puts "Uploading to '#{s3_config['bucket']}'..."

  AWS::S3::S3Object.store(
    'Gem',
    File.open('Gem.zip'),
    s3_config['bucket'],
    :content_type => "application/zip",
    :access => :public_read
  )

  puts "Uploaded!"
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

        puts "Extracting and testing gem..."
        sh 'unzip', '-q', 'Gem.zip'
        sh 'ruby', '-I', 'test:lib', './test/tests.rb'
      end
    end
  end
end

task :deploy do
  sh 'heroku', 'config:set', "LATEST_GEM_VERSION=#{version}", '--app',
     'hammerformac'
end
