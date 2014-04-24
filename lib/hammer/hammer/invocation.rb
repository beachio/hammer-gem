# The class called by the bin stubs. Handles everything to do with creating a new build given arguments.

module Hammer
  class Invocation

    def template=(template)
      @template = template
    end

    def initialize(arguments)
      @cache_directory  = arguments[0]
      @input_directory  = arguments[1]
      @output_directory = arguments[2]
      @success = nil

      @optimized = arguments.include?('PRODUCTION')

      @template = Hammer::HTMLTemplate
      @template = Hammer::CommandLineTemplate if ARGV.include? 'DEBUG'

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

      puts @template.new(results)
      exit @success ? 0 : 1
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
      @success = build.error
      return results
    end
  end
end

require 'hammer/utils/preload'