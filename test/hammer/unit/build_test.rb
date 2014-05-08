#!/usr/bin/env ruby

require 'capture'
require 'rake'
# require 'test_helper'
require 'tmpdir'
require 'hammer/build'

class BuildTest < Test::Unit::TestCase

  context "A build" do

    setup do
      @input_directory = Dir.mktmpdir()

      @build = Hammer::Build.new(
        :input_directory => @input_directory,
        :output_directory => Dir.mktmpdir(),
        :cache_directory => Dir.mktmpdir()
      )

      File.open(File.join(@input_directory, "index.html"), 'w') do |f|
        f.print('This is an HTML file')
      end
    end

    teardown do
      FileUtils.rm_rf @input_directory
    end

    should "return a hash of filename => data" do
      assert_equal ['index.html'], @build.compile.keys
    end

    should "not print ANYTHING when compiling!" do
      assert_equal "", capture_stdout { @build.compile() }.string
    end
  end
end