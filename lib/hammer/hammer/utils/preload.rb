module Hammer
  module Preload

    attr_accessor :wait

    def after_interrupt(&complete)
      protect_against_zombies
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      complete.call(self)
    end

    def self.preload?
      defined?(PRELOAD) || ARGV.include?('PRELOAD')
    end

    def self.included(base)
      return unless self.preload?

      base.class_eval do
        alias_method :compile_without_waiting, :compile
        def compile()
          after_interrupt { compile_without_waiting() }
        end
      end
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

    def wait
      trap('INT') { @triggered = true }
      trap('INT', 'DEFAULT')
      protect_against_zombies
      sleep 0.1 while true
    rescue SystemExit, Interrupt
      self.compile()
    end
  end

  # Include by default yo!
  class Invocation
    include Preload
  end
end