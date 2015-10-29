# The class called by the bin stubs. Handles everything to do with creating a new build given arguments.

require 'hammer/templates/application'
require 'hammer/templates/commandline'

module Hammer
  class Invocation

    def template=(template)
      @template = template
    end

    attr_accessor :cache_directory, :input_directory, :output_directory, :template

    def initialize(arguments)
      @success = nil
      if arguments.length > 1
        @cache_directory, @input_directory, @output_directory = arguments
      else
        @input_directory = arguments[0]
        @cache_directory = Dir.mktmpdir
        @output_directory = File.join @input_directory, "Build"
      end
      @optimized = arguments.include?('PRODUCTION')

      @template = Hammer::ApplicationTemplate

      @start = Time.now
      if ARGV.include? "DEBUG"
        @template = Hammer::CommandLineTemplate
      end
    end

    def compile
      require 'pry' if ARGV.include? 'PRY'
      options = {
        :cache_directory => @cache_directory,
        :input_directory => @input_directory,
        :output_directory => @output_directory,
        :optimized => @optimized
      }
      build = Hammer::Build.new(options)
      results = run(build)

      template = @template.new(results, options)
      output = template.to_s
      output = output.each_line.reject{|x| x.strip == ""}.join
      puts output unless ARGV.include? "-q"
    rescue => e
      template = @template.new([], {})
      template.error = e
      puts template
      @success = false
    ensure
      return @success ? 0 : 1
    end

  private

    def ensure_minimum_half_second
      # # Pause to prevent the UI from returning too quickly and wreaking havoc with FSEvents.
      # # 0.5 minimum script time.
      runtime = Time.now - @start
      # sleep(0.5 - runtime) if runtime < 0.5
    end

    def run(build)
      results = build.compile()
      ensure_minimum_half_second()
      @success = !build.error
      return results
    end
  end
end

require 'hammer/utils/preload'