require_relative 'image_optimizer/shell'
require_relative 'image_optimizer/image_optimizer_base'
require_relative 'image_optimizer/pngout_optimizer'

class ImageOptimizer
  include Shell

  attr_reader :path, :options, :output_path
  def initialize(path, output_path, options = {})
    @path    = path
    @options = options
    @output_path = output_path
  end

  def optimize
    identify_format if options[:identify]
    PNGOutOptimizer.new(path, output_path, options).optimize
  end

private

  def identify_format
    if identify_bin?
      match = run_command("#{identify_bin} -ping#{quiet} #{path}").match(/PNG/)
      if match
        options[:identified_format] = match[0].downcase
      end
    else
      warn 'Attempting to retrieve image format without identify installed. Using file name extension instead...'
    end
  end

  def identify_bin?
    !!identify_bin
  end

  def identify_bin
    ENV['IDENTIFY_BIN'] || which('identify')
  end

end
