def assert(name, &thing)
  success = thing.call()
  if success
    print "."
  else
    puts "#{name} failed!"
  end
end

require "tmpdir"

# Here's a thing. We're not checking wait_thread's exit status, 
# because in Ruby 1.8.7 you don't get it. Sucks to be us!
# Larry told me to use open3 instead of backticks.

require "open3"
include Open3

def run_integration_test(optimized)
  input_directory  = File.join('test', 'integration', 'case1')
  output_directory = Dir.mktmpdir('Build')
  cache_directory  = Dir.mktmpdir('cache')

  output = nil
  error = nil
  status = nil

  puts "Testing #{optimized ? 'optimized' : 'standard'} integration"

  args = ['/usr/bin/ruby', 'hammer_time.rb', cache_directory,
          input_directory, output_directory]
  args << 'PRODUCTION' if optimized

  Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
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

  puts
ensure
  FileUtils.remove_entry output_directory
  FileUtils.remove_entry cache_directory
end

[false, true].each do |optimized|
  run_integration_test optimized
end
