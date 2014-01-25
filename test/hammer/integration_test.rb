require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/test_helper'
require 'pathname'
require 'open3'

# This tests the actual command line syntax.
class HammerGemIntegrationTest < Test::Unit::TestCase

  def integrate_and_test(input_directory, optimized = false)

    output_directory = Dir.mktmpdir('Build')
    cache_directory  = Dir.mktmpdir('cache')

    output = nil
    error = nil
    status = nil

    filename = File.dirname(File.dirname(File.dirname(__FILE__)))
    filename = File.join(filename, 'hammer_time.rb')

    args = [ruby, filename, cache_directory,
            input_directory, output_directory]
    args << 'PRODUCTION' if optimized

    Open3.popen3(*args) do |stdin, stdout, stderr, wait_thread|
      output = stdout.read
      error = stderr.read
    end

    # TODO: check integration does more than just length > 0
    assert output.length > 0, "The command #{args.join(' ')} had no output."
    return output
  end

  def test_integration
    dirs = functional_test_directories
    assert dirs.length > 0
    
    threads = []
    dirs.each do |dir|
      threads << Thread.new do
        integrate_and_test(File.join(dir, 'input'))
      end
    end
    threads.each {|t| t.join}
  end

  def ruby
    # if File.exist? '/usr/bin/ruby'
      # puts "Using /usr/bin/ruby"
      # "/usr/bin/ruby"
    # else
      puts "Using #{which(ruby)}"
      which(ruby)
    # end
  end

  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable? exe
      }
    end
    return nil
  end
end