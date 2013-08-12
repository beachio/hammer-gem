task :default => [:test]

desc 'Run the test suite'
task :test do
  ruby "-I test test/tests.rb"
  `rm -rf .sass-cache`
  Rake::Task['integration'].execute
end

desc 'Run the integration tests'
task :integration do
  ruby "integration.rb"
end

task :check_s3_credentials do
  if !File.exist?("s3.yml")
    puts "Whoops! I couldn't find s3.yml. You have to set up s3.yml before you get started."
    exit
  end
end

task :check_hammer_app_access do
  puts "Checking for Hammer app access..."
  unless `heroku config --app hammerformac`.include? 'LATEST_GEM_VERSION'
    puts "Whoops! No access to hammerformac.herokuapp.com "
    puts "Please ensure that 'heroku config --app hammerformac' works."
    exit
  end
end

desc "Release a gem!"
task :release => [ :check_hammer_app_access, :check_s3_credentials ] do
  require 'yaml'
  require 'rubygems'
  require 'aws/s3'

  version = open("VERSION").read
  s3_config = YAML.load_file("./s3.yml")
  
  puts "All right! We're good to go."
  puts "Today we'll be zipping, uploading and releasing version #{version}"
  puts "Ready to roll! Cancel this task now if you're not ready! <3"
  
  sleep 2
  
  puts "Let's do this."
  
  # Gem.zip is used by the upload server as the filename in the S3 bucket that we redirect to.
  filename = "Gem.zip"
  
  if File.exist? filename
    puts "Deleting the #{filename} that I found"
    `rm #{filename}`
  end
  
  puts "Zipping to #{filename}"
  `zip -o #{filename} -r *`
  
  AWS::S3::Base.establish_connection!(
    :access_key_id     => s3_config['aws_access_key'],
    :secret_access_key => s3_config['aws_secret_access_key']
  )

  local_file = filename
  base_name = File.basename(local_file)
  puts "Uploading #{local_file} to '#{bucket}'..."
  
  AWS::S3::S3Object.store(
    base_name,
    File.open(local_file),
    s3_config['bucket'],
    :content_type => "application/zip",
    :access => :public_read
  )

  puts " - Finished!"
  puts "Setting the LATEST_GEM_VERSION in Heroku app 'hammerformac'"
  puts `heroku config:set LATEST_GEM_VERSION=#{version} --app hammerformac`
  puts "Done! We're now live on #{version}."
  
  puts "Testing http://hammer-updates.s3.amazonaws.com/Gem.zip ..."
  
  require "tmpdir"
  require "zlib"
  require "open-uri"
  Dir.mktmpdir "testing-build" do |dir|
    Dir.chdir(dir)
    `wget http://hammer-updates.s3.amazonaws.com/Gem.zip`
    `unzip Gem.zip -d #{dir}`
    `cd #{dir} && rake`
  end

  puts "We're done here. Later!"
end