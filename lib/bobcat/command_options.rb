module Bobcat
  class CommandOptions
    def parse!(args)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage "

        options[:daemon] = false
        options[:mode]   = 'nonblocking'

        opts.on('-d', '--daemon', 'Start service as daemon') do
          options[:daemon] = true
        end

        opts.on('-m type', '--mode type', 'Thrift mode' ) do |value|
          options[:mode] = value
        end

        opts.on('-p value', '--port value', 'Thrift start at port') do |value|
          options[:port] = value
        end
      end

      begin
        opt_parser.parse! args
      rescue OptionParser::InvalidOption => e
        warn e.message
        abort opt_parser.to_s
      end
      options
    end
  end
end