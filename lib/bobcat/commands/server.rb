require_relative 'application_loader'
require 'bobcat/server/handler'

module Bobcat
  module Commands
    class Server
      include ApplicationLoader

      def start!(thrift_mode)
        # 加载项目
        load_application
        @thrift_mode = thrift_mode
        if thrift_mode == 'thread'
          start_thread_pool_server!
        else
          start_non_blocking_server!
        end
      end

      def start_thread_pool_server!

      end

      def start_non_blocking_server!
        process           = ::Bobcat::config.thrift_processor.new(Bobcat::Server::Handler.new(::ApplicationService))
        transport         = ::Thrift::ServerSocket.new(::Bobcat.config.binding, ::Bobcat.config.port)
        transport_factory = ::Thrift::FramedTransportFactory.new
        protocol_factory  = ::Thrift::BinaryProtocolFactory.new
        num_threads       = ::Bobcat.config.thrift_threads
        logger            = ::ActiveSupport::Logger.new(Bobcat.root.join("log/thrift_server_#{Bobcat.env}.log"))

        @thrift_server = ::Thrift::NonblockingServer.new(process, transport, transport_factory, protocol_factory, num_threads, logger)

        puts "=>Booting bobcat with NonBlcking ....."
        puts "=>Server: 127.0.0.1:#{::Bobcat.config.port}"

        begin
          @thrift_server.serve
        rescue => e
          puts "Starting thrift server failed\n #{e.inspect}"
          puts e.backtrace
        end
      end
    end
  end
end