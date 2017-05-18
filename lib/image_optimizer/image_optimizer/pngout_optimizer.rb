class ImageOptimizer
  class PNGOutOptimizer < ImageOptimizerBase

  private

    def command_options
      [path, output_path, "-y"]
    end

    def extensions
      %w[png]
    end

    def type
      'png'
    end

    def bin_name
      'pngout'
    end

  end
end
