require "digest"

module Hammer
  class HammerFile
    attr_accessor :cached
  end
end

module Hammer
  class ProjectCacher
    
    attr_writer :directory
    attr_accessor :hammer_files, :directory, :input_directory

    extend Forwardable
    def_delegators :@hammer_project, :find_files

    def hammer_project=(hammer_project)
      @hammer_project = hammer_project
      @input_directory = hammer_project.input_directory
      @hammer_files = hammer_project.hammer_files
    end

    # Start this off with a hammer_project. It belongs to the project.
    def initialize(options={})
      @hashes_from_previous_build = {}

      @hammer_project = options.fetch(:hammer_project)  if options.include? :hammer_project
      @input_directory = options.fetch(:input_directory) if options.include? :input_directory

      # The actual directory where the caching happens.
      @directory = options.fetch(:directory) if options.include? :directory
      @directory ||= Dir.mktmpdir
      
      @hard_dependencies = {}
      
      @hammer_files = []
      @hashes_from_this_build = {}
      @new_dependency_hash = {}
      @new_hard_dependencies = {}

      read_from_disk
      create_hashes
    end
    
    def clear
      FileUtils.rm_rf(@directory) if @directory
    end
    
    def valid_cache_for(path)
      if !needs_recompiling? path
        if File.exists?(cached_path_for(path))
          return true
        end
      end
      false
    end
    
    ## The data digest. Opens the directory and writes out to cache.data.
    ## Written to and read from for hashes and things.
    def read_from_disk
      return true unless @directory

      @dependency_hash = {}
      @hashes_from_previous_build = {}
      
      path = cached_path_for("cache.data")
      if File.exists? path
        begin
          contents = File.open(path) do |file|
            Marshal.load(file)
          end
        rescue EOFError
          File.delete(path)
          contents = ""
        end
        
        if contents && contents != ""
          @files_digest = contents[:files_digest] if contents[:files_digest]
          @dependency_hash = contents[:dependency_hash] if contents[:dependency_hash]
          @hard_dependencies = contents[:hard_dependencies] if contents[:hard_dependencies]
          @new_dependency_hash = @dependency_hash
          @hashes_from_previous_build = contents[:hashes] if contents[:hashes]
          @messages = contents[:messages] if contents[:messages]
        end
      end
    end

    def create_hashes
      return unless @input_directory
      path = File.join(@input_directory, "/**/*")
      Dir.glob(path).each do |file|
        path = file[@input_directory.length+1..-1]
        @hashes_from_this_build[file] = hash(path)
      end
    end

    # When finished:
    def write_to_disk
      @dependency_hash = @new_dependency_hash
      @hashes_from_previous_build = @hashes_from_this_build
      @hard_dependencies = @new_hard_dependencies
      @files_digest = @new_files_digest
      
      contents = {
        :messages => @messages, 
        :dependency_hash => @dependency_hash, 
        :hashes => @hashes_from_previous_build, 
        :hard_dependencies => @hard_dependencies, 
        :files_digest => @files_digest
      }
      
      return true unless @directory
      path = File.join(@directory, "cache.data")
      
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |f|     
        f.write Marshal.dump(contents)
      end
    end

    ## Cache path management

    def cached_path_for(path)
      File.join(@directory, path)
    end

    ## Setting and getting stuff for a given path

    # This copies a file at full_path to a file at cached_path_for(path).
    def cache(full_path, path)
      return false unless @directory
      FileUtils.mkdir_p File.dirname(cached_path_for(path))
      FileUtils.cp full_path, cached_path_for(path)
    end

    def copy(filename, output_path)
      FileUtils.rm output_path
      FileUtils.cp(cached_path_for(filename), output_path)
    end

    def cached_contents_for(path)
      path = cached_path_for(path)
      File.open(path).read
    end
    
    def clear_cached_contents_for(path)
      path = cached_path_for(path)
      if File.exist? path
        FileUtils.rm(path)
      end
    end
    
    def set_cached_contents_for(path, contents)
      path = cached_path_for(path)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "w") do |f|
        f.write(contents)
      end
    end

    # Messages are the line-by-line information that goes with every file. 
    # Todos and errors.
    def messages
      return @messages if @messages
      messages_hash = {}
      hammer_files.each do |hammer_file|
        if hammer_file.messages.any?
          messages_hash[hammer_file.filename] = Marshal.dump hammer_file.messages
        end
      end
      @messages = messages_hash
    end

    def messages_for(path)
      if messages[path]
        Marshal.load messages[path]
      else
        []
      end
    end

    ## These are used to add wildcard and file dependencies
    ## to a certain path. These are used for needs_recompiling because
    ## the cacher handles dependencies.
    def add_wildcard_dependency(path, query, type)
      results = find_files(query, type).collect(&:filename)
      results -= [path]
      if results
        @new_dependency_hash[path] ||= {}
        @new_dependency_hash[path][query] ||= {}
        @new_dependency_hash[path][query][type] = results
      end
    end
    
    def add_file_dependency(file_path, dependency_path)
      extension = File.extname(dependency_path)[1..-1]
      if Hammer::Parser.for_extension(extension).length == 0
        return
      end
      
      if dependency_path
        @new_hard_dependencies[file_path] ||= []
        unless @new_hard_dependencies[file_path].include? dependency_path
          @new_hard_dependencies[file_path] << dependency_path
          @new_hard_dependencies[file_path] = @new_hard_dependencies[file_path].uniq
        end
      end
    end

  private

    # This checks a file to see whether it needs recompiling.
    # This method needs to be cached so we're not checking the files all day long.
    def needs_recompiling?(path)
      @needs_recompiling ||= {}
      if @needs_recompiling[path] != nil
        result = @needs_recompiling[path]
      else
        result = needs_recompiling_without_cache(path)
        @needs_recompiling[path] = result
      end

      if !result && path && @hard_dependencies[path]
        @new_hard_dependencies[path] = @hard_dependencies[path]
      end

      return result
    end

    def file_changed(path)
      # @hashes_from_this_build[path] != hash(path)
      @hashes_from_this_build[path] ||= hash(path)
      new_hash = @hashes_from_this_build[path]
      
      # # Yes if the file is modified.
      if new_hash != @hashes_from_previous_build[path]
        @new_dependency_hash.delete(path)
        return true 
      end
      
      return false
    end

    def hard_dependencies_need_recompiling_for(path)
      return false unless @hard_dependencies[path]
      @hard_dependencies[path].each do |dependency|
        next if dependency == path
        if needs_recompiling_without_cache(dependency) || needs_recompiling?(dependency)
          return true
        end
        # return needs_recompiling_without_cache(dependency) || needs_recompiling?(dependency)
      end
    end

    def wildcard_dependencies_need_recompiling_for(path)
      if files_added_or_removed
        if @dependency_hash[path]
          # Yes if the file's references have changed (new files).
          @dependency_hash[path].each_pair do |query, matches|
            
            next if query.nil?
            matches.each do |type, filenames|
              files = find_files(query, type)

              # return true if files.collect(&:filename) != filenames
              if files.collect(&:filename) != filenames
                return true
              end

              # Yes if any dependencies need recompiling. 
              # files.each do |file|
              #   return true if needs_recompiling?(file.filename)
              # end
            end
          end
        end
      end
    end

    def needs_recompiling_without_cache(path)
      if file_changed(path)
        @new_dependency_hash.delete(path)
        return true
      end

      return true if hard_dependencies_need_recompiling_for(path)
      return true if wildcard_dependencies_need_recompiling_for(path)
      
      # File #{path} was not modified.
      return false
    end
  
    def files_added_or_removed
      if @files_added_or_removed == nil
        current_files_digest = Digest::MD5.hexdigest hammer_files.collect(&:filename).join("")
        @files_added_or_removed = current_files_digest != @files_digest
        @new_files_digest = current_files_digest
      end
      return @files_added_or_removed
    end
    
    # TODO: CHange this from reading the whole file.
    # We may be able to do this with timestamps instead. Might be a better approach.
    def hash(path)
      return nil unless @input_directory
      full_path = File.join(@input_directory, path)
      md5 = Digest::MD5.file(full_path).hexdigest
    rescue
      nil
    end
    
  end
end