require 'bobcat'
require 'bobcat/commands/server'
module Bobcat
  class HandleProcess
    class << self
      attr_accessor :options, :daemon, :thrift_mode, :app_name, :pid_file

      def init(opts = {})
        self.app_name    = Bobcat.config.app_name
        self.thrift_mode = opts[:thrift_mode]
        self.app_name    = "#{Bobcat::HandleProcess.app_name}-thread" if self.thrift_mode == "thread"
        self.pid_file    = Bobcat.root.join("tmp/#{Bobcat::HandleProcess.app_name}.pid")
        self.daemon      = opts[:daemon]
      end

      def start_process
        old_pid = read_pidfile
        if !old_pid.nil?
          # TODO: add color
          puts ("#{app_name} process is running on pid #{old_pid}")
          return
        end

        @master_process_id = generate_master_process!
        File.open(pid_file, "w+") do |f|
          f.puts @master_process_id
        end

        puts "=>Started #{app_name} on pid: #{@master_process_id}"

        if self.daemon
          # 使主进程交由init进程接管，变成守护进程
          exit
        else
          Process.waitpid(@master_process_id)
        end
      end

      def restart_process

      end

      def stop_process

      end

      private

      def read_pidfile
        if !File.exist?(pid_file)
          return nil
        end

        pid = File.open(pid_file).read.to_i
        begin
          Process.getpgid(pid)
        rescue
          pid = nil
        end
        pid
      end

      def generate_master_process!
        fork do
          $PROGRAM_NAME = self.app_name + " [babcat master]"
          @child_pid = generate_child_process!
          Signal.trap("QUIT") do
            Process.kill("QUIT", @child_pid)
            exit
          end

          Signal.trap("USR1") do
            Process.kill("USR1", @child_pid)
          end

          loop do
            sleep 1
            begin
              Process.getpgid(@child_pid)
            rescue Errno::ESRCH
              @child_pid = generate_child_process!
            end
          end

        end
      end

      def generate_child_process!
        pid = fork do
          $PROGRAM_NAME = self.app_name + " [bobcat child]"
          Signal.trap("QUIT") do
            exit
          end

          Signal.trap("USR1") do
            exit
          end

          if self.daemon
            redirect_stdout
          else
            log_to_stdout
          end
           Bobcat::Commands::Server.new.start!(self.thrift_mode)
        end

        # 分离子进程，防止子进程变成僵尸进程
        Process.detach(pid)
        pid
      end

      # IO流指向日志文件
      def redirect_stdout
        $stdout.reopen(Bobcat.logger_path, "w")
        $stderr.reopen(Bobcat.logger_path, "w")
      end

      # 日志信息打印到终端，并记录到log文件
      def log_to_stdout
        console = ActiveSupport::Logger.new(STDOUT)
        console.formatter = Bobcat.logger.formatter

        Bobcat.logger.extend(ActiveSupport::Logger.broadcast(console))
      end


    end
  end
end