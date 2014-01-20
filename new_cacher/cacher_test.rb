require 'byebug'
require './cacher'
require 'test/unit'
require 'shoulda-context'
require 'mocha/setup'
require 'tmpdir'
require 'fileutils'

class CacherTest < Test::Unit::TestCase
  
  context "given a cacher" do
    setup do
      @input_directory = Dir.mktmpdir
      @directory = Dir.mktmpdir
      @options = {:input_directory => @input_directory, :directory => @directory}
      @cacher = Hammer::Cacher.new @options
    end

    should "have initialized" do
      assert @cacher
    end

    context "with a file that exists" do

      setup do
        @file = File.join @input_directory, 'index.html'
        File.open(@file, 'w') {|f| f.puts "a"}
      end

      should "cache it and copy it back out" do
        @cacher.cache 'index.html', @file
        new_path = File.join Dir.mktmpdir, 'index.html'
        @cacher.copy_from_cache 'index.html', new_path
        assert_equal File.open(@file).read, File.open(new_path).read
      end

      should "cache it and uncache it" do
        @cacher.cache 'index.html', @file
        @cacher.uncache 'index.html'
        new_path = File.join Dir.mktmpdir, 'index.html'

        assert_raises do
          @cacher.copy_from_cache 'index.html', new_path
        end
      end

      should "save messages for a file" do
        messages = {'name' => 'Test'}
        @cacher.add_messages 'index.html', messages
        assert_equal [messages], @cacher.messages_for('index.html')
      end

      should "add a file dependency" do
        @cacher.add_file_dependency 'index.html', 'include.html'
        assert_equal({'index.html' => ['include.html']}, @cacher.instance_variable_get('@hard_dependencies'))
      end

      should "add a wildcard dependency" do
        object = Object.new
        @cacher.add_wildcard_dependency 'index.html', 'index', 'html', object
        assert_equal({'index.html' => {'index' => {'html' => object}}}, @cacher.instance_variable_get('@wildcard_dependencies'))
      end

      should "read and write to disk" do
        @cacher.read_files
        @cacher.write_to_disk
        cacher2 = Hammer::Cacher.new @options
        cacher2.read_from_disk
        assert_equal @cacher.hashes, cacher2.hashes
        assert_equal @cacher.hashes, cacher2.previous_build_hashes
      end

      should "read and write hashes and know when a file has changed" do
        @cacher.read_files
        @cacher.write_to_disk
        File.open(@file, 'w') {|f| f.puts "b"}
        cacher2 = Hammer::Cacher.new @options
        assert_equal @cacher.hashes, cacher2.previous_build_hashes
        assert @cacher.hashes != cacher2.hashes
      end

      should "use previous_build_hashes and hashes to see when a file's changed" do
        @cacher.stubs(:previous_build_hashes).returns({'index.html' => 'a'})
        @cacher.stubs(:hashes).returns({'index.html' => 'b'})
        assert @cacher.file_changed? 'index.html'
        assert !@cacher.cached?('index.html')
      end

      should "know when a dependency has changed" do
        @cacher.add_file_dependency 'index.html', 'include.html'
        @cacher.stubs(:file_changed?).with('index.html').returns(false)
        @cacher.stubs(:file_changed?).with('include.html').returns(true)
        assert !@cacher.cached?('index.html')
      end

      should "know when a wildcard dependency has changed" do
        file = Object.new
        file.stubs(:filename).returns('include.html')
        @cacher.add_wildcard_dependency 'index.html', 'include', 'html', []
        @cacher.write_to_disk
        @cacher.read_from_disk
        @cacher.stubs(:find_files).returns [file]
        assert @cacher.wildcard_dependency_changed?('index.html')
        assert !@cacher.cached?('index.html')
      end
    end
  end
end