module Bobcat
  class CommandsTask

    COMMANDS_WHITELIST = %w(start restart stop console help)

    HELP_MESSAGE = <<-EOT
Usage: bobcat COMMAND [ARGS]
The most common bobcat commands are:
start       Start the server
restart     Restart the server
stop        Stop the console
console     Start the  console
test        Run tests
EOT


    def initialize(argv)
      @argv = argv
    end

    def run_command!(command)
      if COMMANDS_WHITELIST.include?(command)
        send(command)
      else
        help
      end
    end

    def start
      require_relative 'command_options'
      require_relative 'handle_process'

      options = ::Bobcat::CommandOptions.new().parse!(ARGV)
      Bobcat::HandleProcess.init(thrft_mode: options[:mode], daemon: options[:daemon])
      Bobcat::HandleProcess.start_process
    end

    def restart

    end

    def stop

    end

    def console

    end

    def help
      puts HELP_MESSAGE
    end
  end
end

ARGV << '--help' if ARGV.empty?
command = ARGV.shift
Bobcat::CommandsTask.new(ARGV).run_command!(command)