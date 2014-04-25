# The class called by the bin stubs. Handles everything to do with creating a new build given arguments.

require 'hammer/templates/application'

module Hammer
  class Invocation

    def template=(template)
      @template = template
    end

    def initialize(arguments)
      @success = nil
      @cache_directory, @input_directory, @output_directory = arguments
      @optimized = arguments.include?('PRODUCTION')

      if ARGV.include? 'DEBUG'
        require 'hammer/templates/commandline'
        @template = Hammer::CommandLineTemplate
      else
        @template = Hammer::ApplicationTemplate
      end

      @start = Time.now
      @debug = arguments.include? "DEBUG"
    end

    def compile
      options = {
        :cache_directory => @cache_directory,
        :input_directory => @input_directory,
        :output_directory => @output_directory,
        :optimized => @optimized
      }

      build = Hammer::Build.new(options)
      results = run(build)

      template = @template.new(results, options)
      puts template
      return @success ? 0 : 1
    end

  private

    def ensure_minimum_half_second
      # # Pause to prevent the UI from returning too quickly and wreaking havoc with FSEvents.
      # # 0.5 minimum script time.
      runtime = Time.now - @start
      sleep(0.5 - runtime) if runtime < 0.5
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