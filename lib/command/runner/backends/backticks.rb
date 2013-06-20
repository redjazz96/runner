module Command
  class Runner
    module Backends

      # A backend that uses ticks to do its bidding.
      class Backticks

        # Returns whether or not this backend is avialable on this
        # platform.
        def self.available?
          true
        end

        # Initialize the fake backend.
        def initialize
          super
        end

        # Run the given command and arguments, in the given environment.
        #
        # @abstract
        # @note Does nothing.
        # @param command [String] the command to run.
        # @param arguments [String] the arguments to pass to the
        #   command.
        # @param env [Hash] the enviornment to run the command
        #   under.
        # @param options [Hash] the options to run the command under.
        # @return [Message] information about the process that ran.
        def call(command, arguments, env = {}, options = {})
          super
          output = ""
          start_time = nil
          end_time = nil

          with_modified_env(env) do
            start_time = Time.now
            output << `#{command} #{arguments}`
            end_time = Time.now
          end

          Message.new process_id: $?.pid,
            exit_code: $?.exitstatus, finished: true,
            time: (start_time - end_time).abs, env: env,
            options: {}, stdout: output, line: line,
            executed: true, status: $?
        end

        private

        # If ClimateControl is installed on this system, it runs the
        # given block with the given environment.  If it's not, it
        # just yields.
        #
        # @yield
        # @return [Object]
        def with_modified_env(env)
          if defined?(ClimateControl) || climate_control?
            ClimateControl.modify(env, &Proc.new)
          else
            yield
          end
        end

        # Checks to see if ClimateControl is on this system.
        #
        # @return [Boolean]
        def climate_control?
          begin
            require 'climate_control'
            true
          rescue LoadError
            false
          end
        end

      end
    end
  end

end