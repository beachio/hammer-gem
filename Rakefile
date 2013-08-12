task :default => [:test]

desc 'Run the test suite'
task :test do
  ruby "-I test test/tests.rb"
  `rm -rf .sass-cache`
  Rake::Task['integration'].execute
end

task :version do
  puts open("VERSION").read
end

desc "Bump the version by 0.0.1"
namespace :version do
  task :bump do
    current_version = open("VERSION").read
    new_version = current_version.split(".").join("")
    new_version = (new_version.to_i + 1).to_s
    new_version = new_version.split("").join(".")
    puts "Bumping from #{current_version} to #{new_version}"
    File.open("VERSION", 'w') do |f|
      f.write new_version
    end
  end
end

desc 'Run the integration tests'
task :integration do
  ruby "integration.rb"
end

task :check_hammer_app_access do
  puts "Checking for Hammer app access..."
  sh 'heroku', 'config:get', 'LATEST_GEM_VERSION', '--app', 'hammerformac'
end

file "Gem.zip" => `git ls-files -z`.split("\0") do |t|
  sh 'zip', '-o', t.name, '-r', *t.prerequisites
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

def s3_config
  YAML.load_file('s3.yml')
end

def version
  open("VERSION").read.strip
end

desc "Test the released version of the Hammer compiler"
task :test_release do
  puts "Testing http://hammer-updates.s3.amazonaws.com/Gem.zip ..."
  require "tmpdir"
  require "zlib"
  require "open-uri"
  Dir.mktmpdir "testing-build" do |dir|
    Dir.chdir(dir)
    `wget http://hammer-updates.s3.amazonaws.com/Gem.zip`
    `unzip Gem.zip -d #{dir}`
    system "cd #{dir} && rake"
  end
end

task :mark_release do
  sh 'heroku', 'config:set', "LATEST_GEM_VERSION=#{version}", '--app',
     'hammerformac'
end

desc "Release a gem!"
task :release => [ :check_hammer_app_access, :upload_gem, :mark_release, :test_release ] do
  puts "Done! We're now live on #{version}. Go test it."
end
