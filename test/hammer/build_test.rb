#!/usr/bin/env ruby

require 'rake'
require 'test_helper'
require 'tmpdir'

class BuildTest < Test::Unit::TestCase

  context "A build" do

    setup do

      @input_directory = Dir.mktmpdir()

      @build = Hammer::Build.new(
        :input_directory => @input_directory,
        :output_directory => Dir.mktmpdir(),
        :cache_directory => Dir.mktmpdir()
      )

      index_file = File.join(@input_directory, "index.html")
      File.open(index_file, 'w') do |f|
        f.puts('This is an HTML file')
        f.close()
      end
    end

    teardown do
    end

    should "parse" do
      assert_equal({}, @build.compile())
    end

    should "have filenames" do
       assert_equal(["index.html"], @build.filenames)
    end
  end

end