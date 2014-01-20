require "digest"

module Hammer
  class HammerFile
    attr_accessor :cached
  end
end

module Hammer
  class Cacher

    attr_accessor :hashes, :previous_build_hashes, :directory

    def initialize options = {}

      @hard_dependencies ||= {}

      # The project directory we're looking at
      @input_directory = options.fetch(:input_directory) if options.include? :input_directory
      @hammer_project = options.fetch(:hammer_project) if options.include? :hammer_project

      # The actual directory where the caching happens.
      if options.include? :directory
        @directory = options.fetch(:directory) 
      else
        @directory = Dir.mktmpdir
      end

      @previous_build_hashes = {}

      read_from_disk
      read_files
    end

    # Caching behaviour

    def cache filename, source_path
      FileUtils.mkdir_p File.dirname(cached_path_for(filename))
      FileUtils.cp source_path, cached_path_for(filename)
    end

    def cache_contents filename, contents
      FileUtils.mkdir_p(File.dirname cached_path_for(filename))
      File.open cached_path_for(filename), 'w' do |f|
        f.puts contents
      end
    end

    def copy_from_cache filename, destination_path
      FileUtils.cp cached_path_for(filename), destination_path
    rescue Errno::ENOENT
      raise "No cache file for #{filename}!"
    end

    def uncache filename
      FileUtils.rm cached_path_for(filename)
    end

    def cached? filename
      return false if file_changed? filename
      return false if dependency_changed? filename
      return false if wildcard_dependency_changed? filename
      return false if !File.exists?(cached_path_for(filename))
      true
    end

    # File messages

    def messages_for filename
      @messages ||= {}
      @messages[filename]
    rescue
      []
    end

    def add_messages filename, messages
      @messages ||= {}
      @messages[filename] ||= []
      @messages[filename] << messages
    end

    # File dependencies

    def add_file_dependency filename, dependency_filename
      @hard_dependencies ||= {}
      @hard_dependencies[filename] ||= []
      @hard_dependencies[filename] << dependency_filename
      @hard_dependencies[filename] = @hard_dependencies[filename].uniq
    end

    def add_wildcard_dependency path, query, type, filenames
      @wildcard_dependencies ||= {}
      @wildcard_dependencies[path] ||= {}
      @wildcard_dependencies[path][query] ||= {}
      @wildcard_dependencies[path][query][type] = filenames
    end

    def cached_path_for filename
      File.join @directory, filename
    end

    # writing and reading

    def write_to_disk
      contents = {
        :messages => @messages, 
        :hashes => @hashes, 
        :wildcard_dependencies => @wildcard_dependencies, 
        :hard_dependencies => @hard_dependencies, 
        :files_digest => @files_digest
      }
      path = File.join(@directory, "cache.data")
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |f|     
        f.write Marshal.dump(contents)
      end
    end

    def read_from_disk
      return true unless @directory
      path = cached_path_for("cache.data")

      return unless File.exists? path

      contents = File.open(path) do |file|
        Marshal.load(file)
      end
        
      if contents && contents != ""
        @files_digest = contents[:files_digest] if contents[:files_digest]
        @wildcard_dependencies_from_previous_build = contents[:wildcard_dependencies] if contents[:wildcard_dependencies]
        @hard_dependencies = contents[:hard_dependencies] if contents[:hard_dependencies]
        @messages = contents[:messages] if contents[:messages]
        @previous_build_hashes = contents[:hashes] if contents[:hashes]
      end
    end

    def read_files
      @hashes ||= {}
      path = File.join(@input_directory, "/**/*")
      Dir.glob(path).each do |file|
        next if File.directory? file
        path = file[@input_directory.length+1..-1]
        @hashes[file] = hash(path)
      end
    end 

    ###### Testing for changes

    def file_changed? filename
      hashes[filename] != previous_build_hashes[filename]
    end

    def dependency_changed? filename
      return false if !@hard_dependencies[filename]
      @hard_dependencies[filename].each do |dependency|
        return true if file_changed?(dependency)
      end
    end

    extend Forwardable
    def_delegators :@hammer_project, :find_files

    def wildcard_dependency_changed? filename

      return false unless @wildcard_dependencies_from_previous_build

      # return false unless files_added_or_removed 
      if @wildcard_dependencies_from_previous_build[filename]
        # Yes if the file's references have changed (new files).
        @wildcard_dependencies_from_previous_build[filename].each_pair do |query, matches|
          
          next if query.nil?
          matches.each do |type, filenames|

            return true if @wildcard_dependencies[filename][query][type] != filenames

            files = find_files(query, type)
            return true if files.collect(&:filename) != filenames

            # Yes if any dependencies need recompiling. 
            files.each do |file|
              return true if needs_recompiling?(file.filename)
            end
          end
        end
      end
    end

    #### Get the contents of a file

    def hash filename
      full_path = File.join(@input_directory, filename)
      md5 = Digest::MD5.file(full_path).hexdigest
    end

  end
end