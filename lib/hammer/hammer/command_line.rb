module Hammer
  class Invocation

    def template=(template)
      @template = template
    end

    def initialize
      @template = Hammer::HTMLTemplate
      @start = Time.now
      @interrupted = false
      build
    end

    def compile
      if ARGV.include?('PRELOAD') and !@interrupted
        wait { run() }
      else
        run()
      end
    end

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

    def wait(&complete)
      protect_against_zombies
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      complete.call(self)
    end

    # This process kills the build if this process's parent process exits.
    def protect_against_zombies
      Thread.new do
        while true
          exit if Process.ppid == 1
          sleep 1
        end
      end
    end

    def delay
      # # Pause to prevent the UI from returning too quickly and wreaking havoc with FSEvents.
      # # 0.5 minimum script time.
      runtime = Time.now - @start
      sleep(0.5 - runtime) if runtime < 0.5
    end

    def run
      results = build.compile()

      delay()
      
      # @template = Hammer::CommandLineTemplate if ARGV.include? 'DEBUG'
      puts @template.new(results)

      exit build.error ? 1 : 0
    end
  end
end