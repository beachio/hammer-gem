require 'test_helper'
require 'hammer/utils/ignore'

module Hammer
  class IgnoreThing
    include Ignore
  end
end

class HammerIgnoreTest < Test::Unit::TestCase
  context "Ignore" do
    setup do
      @parser = Hammer::IgnoreThing.new
      @directory = Dir.mktmpdir
      FileUtils.mkdir_p @directory
      @ignore_file = File.join(@directory, '.hammer-ignore')
    end

    should "find files in a directory" do
      File.open(File.join(@directory, 'ignored.html'), 'w') do |f|
        f.puts "Text"
      end

      File.open(@ignore_file, 'w') { |f|
        f.puts "ignored.html"
      }

      assert_equal [], @parser.files_from_directory(@directory, @ignore_file)
      assert @parser.ignored_files_from_directory(@directory, @ignore_file).length >= 1
    end
  end
end