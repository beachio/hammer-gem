module Hammer
  module Paths
    def path_to(other_path)
      if other_path.include?(directory)
        me = Pathname.new(File.join(directory, File.dirname(path)))
      else
        me = Pathname.new(File.dirname(path))
      end

      output_filename = output_filename_for(other_path)
      them = Pathname.new(output_filename)
      them.relative_path_from(me)
    end
  end
end

module Hamemr
  class Parser
    include Hammer::Paths
  end
end