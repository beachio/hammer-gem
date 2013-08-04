def assert(name, &thing)
  success = thing.call()
  if success
    print "."
  else
    puts "#{name} failed!"
  end
end

require "tmpdir"

temp_directory    = Dir.mktmpdir('hammer integration')
input_directory   = File.join('test', 'integration', 'case1')
output_directory  = File.join(temp_directory, "Build")
cache_directory   = File.join(temp_directory, "cache")

output = nil
error = nil
status = nil

# Here's a thing. We're not checking wait_thread's exit status, 
# because in Ruby 1.8.7 you don't get it. Sucks to be us!
# Larry told me ot use open3 instead of backticks.

require "open3"
include Open3

[false, true].each do |optimization|
  FileUtils.rm_rf output_directory
  FileUtils.rm_rf cache_directory
  
  puts
  puts "Testing #{optimization ? 'optimized' : 'standard'} integration"
  
  optimized = optimization ? "PRODUCTION" : ""
  
  Open3.popen3('/usr/bin/ruby', 'hammer_time.rb',
               cache_directory, input_directory, 
               output_directory, "PRODUCTION") do |stdin, stdout, stderr, wait_thread|
    output = stdout.read
    error = stderr.read
  end

  assert "no errors" do 
    error == ""
  end

  assert "We have output" do 
    output.length > 0
  end

  assert "files were created" do
    file = File.join output_directory, 'index.html'
    html_file = File.open(file).read
    html_file.include? "<html>"
  end

  assert "our output doesn't contain errors" do
    !output.include? "build-error"
  end
  
end