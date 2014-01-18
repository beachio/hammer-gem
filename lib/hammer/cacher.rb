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
      puts hammer_project.input_directory
      @input_directory = hammer_project.input_directory
      @hammer_files = hammer_project.hammer_files
    end

    # Start this off with a hammer_project. It belongs to the project.
    def initialize(options={})

      if options.include? :hammer_project
        @hammer_project = options.fetch(:hammer_project) 
      end
      @input_directory = options.fetch(:input_directory)

      @hashes = {}

      @directory = options.fetch(:directory) if options.include? :directory
      @directory ||= Dir.mktmpdir
      
      @hard_dependencies = {}
      
      @hammer_files = []
      @new_hashes = {}
      @new_dependency_hash = {}
      @new_hard_dependencies = {}

      read_from_disk
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
    end
    
    def cache(full_path, path)
      return false unless @directory
      FileUtils.mkdir_p File.dirname(cached_path_for(path))
      # File.delete(cached_path_for(path)) 
      FileUtils.cp full_path, cached_path_for(path)
    end



    ## The data digest. Opens the directory and writes out to cache.data.
    ## Written to and read from for hashes and things.
    def read_from_disk
      return true unless @directory

      @dependency_hash = {}
      @hashes = {}
      
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
          @hashes = contents[:hashes] if contents[:hashes]
          @messages = contents[:messages] if contents[:messages]
        end
      end
    end

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

    # When finished:
    def write_to_disk
      
      @dependency_hash = @new_dependency_hash
      @hashes = @new_hashes
      @hard_dependencies = @new_hard_dependencies
      @files_digest = @new_files_digest
      
      contents = {
        :messages => @messages, 
        :dependency_hash => @dependency_hash, 
        :hashes => @hashes, 
        :hard_dependencies => @hard_dependencies, 
        :files_digest => @files_digest
      }
      
      return true unless @directory
      path = File.join(@directory, "cache.data")
      
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |f|     
        # f.write contents.to_json # 
        f.write Marshal.dump(contents)
      end
    end


    ## Cache path management

    def messages_for(path)
      @messages ||= {}
      if @messages[path]
        Marshal.load @messages[path]
      else
        []
      end
    end
    
    def cached_path_for(path)
      File.join(@directory, path)
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

    # Check a file to see whether it needs recompiling.
    attr_accessor :needs_recompiling
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

    def needs_recompiling_without_cache(path)

      @new_hashes[path] ||= hash(path)
      new_hash = @new_hashes[path]
      
      # # Yes if the file is modified.
      if new_hash != @hashes[path]
        @new_dependency_hash.delete(path)
        return true 
      end
    
      if @hard_dependencies[path]
        @hard_dependencies[path].each do |dependency|
          next if dependency == path
          return needs_recompiling_without_cache(dependency) || needs_recompiling?(dependency)
        end
      end
      
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