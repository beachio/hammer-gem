require "digest"
require 'hammer/parsers/modules/finding_files'
require 'hammer/parsers/modules/extensions'

module Hammer
  class HammerFile
    attr_accessor :cached
  end
end

module Hammer
  class Cacher

    attr_accessor :input_directory, :cache_directory, :output_directory
    attr_accessor :dependencies, :wildcard_dependencies
    attr_accessor :data

    def initialize(input_directory, cache_directory, output_directory)
      @directory = cache_directory

      @dependencies = {}
      @wildcard_dependencies = {}

      @input_directory = input_directory
      @cache_directory = cache_directory
      @output_directory = output_directory

      FileUtils.mkdir_p(@cache_directory)
      @hashes = {}
      @new_hashes = {}
      @data = {}
      read_from_disk()
    end

    def cached? path
      return false if !File.exist?(cached_path_for(path))
      return false if file_changed?(path)
      return false if dependencies_changed?(path)

      return true
    end

    # def cache(path, original_filename, output_filename, data=nil)
    def cache(input_path, output_path, data=nil)
      path = input_path
      @new_hashes[input_path] = hash(@input_directory, input_path)

      if data
        @data[path] = data if data
        @wildcard_dependencies[path] = data[:wildcard_dependencies] if data[:wildcard_dependencies]
        @dependencies[path] = data[:dependencies] if data[:dependencies]
      end

      FileUtils.mkdir_p(File.dirname(cached_path_for(path)))

      if File.exist? File.join(@output_directory, output_path)
        FileUtils.cp(File.join(@output_directory, output_path), cached_path_for(path))
      else
        FileUtils.cp(File.join(@input_directory, input_path), cached_path_for(input_path))
      end
    end

    def copy_to(input_path, output_directory, path)
      # TODO: Why is this cached_path_for(path) and not cached_path_for(input_path)?
      FileUtils.cp(cached_path_for(path), File.join(output_directory, path))
      output_file = File.join(output_directory, path)
      FileUtils.touch(output_file, :mtime => File.mtime(cached_path_for(path)))
    end

    def read_from_disk
      @dependency_hash = {}
      @hashes = {}

      return true unless @directory
      path = File.join(@directory, "cache.data")
      if File.exists? path

        begin
          contents = File.open(path) do |file|
            Marshal.load(file)
          end
        rescue EOFError
          File.delete(path)
          contents = ""
        end

        @hashes = contents[:hashes] || {}
        @data = contents[:data] || {}
        @wildcard_dependencies = contents[:wildcard_dependencies] || {}
        @dependencies = contents[:dependencies] || {}

      end
    end

    # When finished:
    def write_to_disk

      contents = {
        :hashes => @hashes.merge(@new_hashes),
        :data => @data,
        :wildcard_dependencies => @wildcard_dependencies,
        :dependencies => @dependencies
      }

      return true unless @directory
      path = File.join(@directory, "cache.data")

      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |f|
        # f.write contents.to_json #
        f.write Marshal.dump(contents)
      end
    end

  private

    def file_changed?(path)
      # path = path[1..-1] if path.start_with?("/")
      hash(@input_directory, path) != @hashes[path]
    end

    def hash(directory, path)
      full_path = File.join(directory, path)
      mtime = File.mtime(full_path)
      md5 = Digest::MD5.file(full_path).hexdigest
    rescue
      nil
    end

    def cached_path_for(path)
      File.join(@cache_directory, path)
    end


  #     # # Yes if the file is modified.
  #     if new_hash != @hashes[path]
  #       @new_dependency_hash.delete(path)
  #       return true
  #     end
    def dependencies_changed?(path)

      if dependencies = @dependencies[path]
        dependencies.each do |dependency|
          return true if file_changed?(dependency)
        end
      end

      if wildcard_dependencies = @wildcard_dependencies[path]
        wildcard_dependencies.each do |query, results|
          o = Hammer::HTMLParser.new(:path => path, :directory => @input_directory)
          return true if o.find_files(*query) != results
        end
        return false
      end
    end

  #   def messages_for(path)
  #     @messages ||= {}
  #     if @messages[path]
  #       Marshal.load @messages[path]
  #     else
  #       []
  #     end
  #   rescue
  #     []
  #   end


  #   def needs_recompiling_without_cache(path)

  #     # return true if DEBUG

  #     @new_hashes[path] ||= hash(path)
  #     new_hash = @new_hashes[path]

  #     # # Yes if the file is modified.
  #     if new_hash != @hashes[path]
  #       @new_dependency_hash.delete(path)
  #       return true
  #     end


  #     if @hard_dependencies[path]
  #       # p "Dependencies for #{path}:"
  #       @hard_dependencies[path].each do |dependency|
  #         # p "&nbsp;&nbsp;&nbsp;#{dependency}"
  #         next if dependency == path

  #         # p "Nested dependencies: "
  #         # p @hard_dependencies[dependency]

  #         if needs_recompiling_without_cache(dependency)
  #           # p "#{dependency} needs recompiling!"
  #           return true
  #         end

  #         if needs_recompiling?(dependency)
  #           # p "#{dependency} needs recompiling!"
  #           return true
  #         end
  #       end
  #     end

  #     if files_added_or_removed
  #       if @dependency_hash[path]
  #         # Yes if the file's references have changed (new files).
  #         @dependency_hash[path].each_pair do |query, matches|

  #           next if query.nil?
  #           matches.each do |type, filenames|
  #             files = @hammer_project.find_files(query, type)
  #             # return true if files.collect(&:filename) != filenames
  #             if files.collect(&:filename) != filenames
  #               return true
  #             end

  #             # Yes if any dependencies need recompiling.
  #             # files.each do |file|
  #             #   return true if needs_recompiling?(file.filename)
  #             # end
  #           end
  #         end
  #       end
  #     end

  #     # File #{path} was not modified.
  #     return false

  #   end

  #   # Check a file to see whether it needs recompiling.
  #   def needs_recompiling?(path)

  #     @needs_recompiling ||= {}
  #     if @needs_recompiling[path] != nil
  #       result = @needs_recompiling[path]
  #     else
  #       result = needs_recompiling_without_cache(path)
  #       @needs_recompiling[path] = result
  #     end

  #     if !result && path && @hard_dependencies[path]
  #       @new_hard_dependencies[path] = @hard_dependencies[path]
  #     end

  #     return result
  #   end

  #   def add_wildcard_dependency(path, query, type)
  #     begin
  #       results = @hammer_project.find_files(query, type).collect(&:filename)
  #       results -= [path]
  #       if results
  #         @new_dependency_hash[path] ||= {}
  #         @new_dependency_hash[path][query] ||= {}
  #         @new_dependency_hash[path][query][type] = results
  #       end
  #     rescue => e
  #       # puts e.message
  #       # puts e.backtrace
  #     end
  #   end

  #   def add_file_dependency(file_path, dependency_path)

  #     extension = File.extname(dependency_path)[1..-1]
  #     if Hammer.parsers_for_extension(extension).length == 0
  #       return
  #     end

  #     if dependency_path
  #       @new_hard_dependencies[file_path] ||= []
  #       unless @new_hard_dependencies[file_path].include? dependency_path
  #         @new_hard_dependencies[file_path] << dependency_path
  #         @new_hard_dependencies[file_path] = @new_hard_dependencies[file_path].uniq
  #       end
  #     end
  #   end

  #   def files_added_or_removed
  #     if @files_added_or_removed == nil
  #       current_files_digest = Digest::MD5.hexdigest @hammer_project.hammer_files.collect(&:filename).join("")
  #       @files_added_or_removed = current_files_digest != @files_digest
  #       @new_files_digest = current_files_digest
  #     end
  #     return @files_added_or_removed
  #   end

  #   # TODO: CHange this from reading the whole file.
  #   # We may be able to do this with timestamps instead. Might be a better approach.
  #   def hash(path)
  #     return nil unless @hammer_project.input_directory
  #     full_path = File.join(@hammer_project.input_directory, path)
  #     md5 = Digest::MD5.file(full_path).hexdigest
  #   rescue
  #     nil
  #   end

  end
end