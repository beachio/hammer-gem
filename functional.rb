require "tmpdir"
require "pathname"
require "fileutils"
require "open3"
include Open3

def compare_directories a, b
  _compare_directories(a, b)
  _compare_directories(b, a)
end

def _compare_directories a, b
  a_files = Dir.glob(File.join(a, "**/*"))
  b_files = Dir.glob(File.join(b, "**/*"))
  
  a_files.each do |a_file_path|
    
    relative_file_path = Pathname.new(a_file_path).relative_path_from(Pathname.new(a))
    b_file_path = File.join(b, relative_file_path)
    
    raise "File missing: #{a_file_path} wasn't compiled to Build folder" unless File.exist?(b_file_path)
    
    if !File.directory? a_file_path    
      if !FileUtils.compare_file(b_file_path, a_file_path)
  
        raise %Q{
Error in #{relative_file_path} (#{b_file_path} / #{a_file_path}):


Expected output:    (#{b_file_path})
----
#{File.open(b_file_path, 'r:UTF-8').read}
----

Actual output:      (File #{a_file_path})
----
#{File.open(a_file_path, 'r:UTF-8').read}
----


        }

      end
      
      print "."
    end
    
  end
end

def run_functional_test(input_directory, reference_directory, optimized)
  output_directory = Dir.mktmpdir('Build')
  cache_directory  = Dir.mktmpdir('cache')

  args = ['/usr/bin/ruby', 'hammer_time.rb', cache_directory, input_directory, output_directory]
  args << 'PRODUCTION' if optimized
  
  Open3.popen3(*args) { |stdin, stdout, stderr, wait_thread| stdout.read }

  return compare_directories(output_directory, reference_directory)
ensure
  FileUtils.remove_entry output_directory
  FileUtils.remove_entry cache_directory
end

@errors = []
@success = true
dirs = File.join('test', 'functional', '*')

Dir.glob(dirs).each do |directory|
  input_directory = File.join(directory, 'input')
  reference_directory = File.join(directory, 'output')
  begin
    # [true, false].each do |optimized|
      test_result = run_functional_test(input_directory, reference_directory, false)
    # end
  rescue => message
    print "F"
    @errors << message
  end
end

puts

if @errors.any?
  @success = false
  puts
  puts "#{@errors.length} errors:"
  @errors.uniq.each do |error|
    print "  "
    puts error
  end
  puts
end

exit @success ? 0 : 1