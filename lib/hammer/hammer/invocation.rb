module Hammer
  class Invocation

    def template=(template)
      @template = template
    end

    def initialize
      @template = Hammer::HTMLTemplate
      @start = Time.now
      build
    end

    def compile
      run()
    end

  private

    def input_directory
      @input_directory ||= ARGV[1] if ARGV[1]
      @input_directory
    end

    def build
      @build ||= Hammer::Build.new(:cache_directory   => ARGV[0],
                                    :input_directory => input_directory,
                                    :output_directory  => ARGV[2],
                                    :optimized   => ARGV.include?('PRODUCTION'))
    end

    def run
      results = build.compile()

      # # Pause to prevent the UI from returning too quickly and wreaking havoc with FSEvents.
      # # 0.5 minimum script time.
      runtime = Time.now - @start
      sleep(0.5 - runtime) if runtime < 0.5
      
      # @template = Hammer::CommandLineTemplate if ARGV.include? 'DEBUG'
      puts @template.new(results)

      exit build.error ? 1 : 0
    end
  end
end

require 'hammer/utils/preload'