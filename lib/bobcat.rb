require "bobcat/version"
require "active_support/all"
require "bobcat/config"

module Bobcat
  class << self
    def config
      return @config if defined?(@config)
      @config = Config.new.config
    end

    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['BOBCAT_ENV'] || 'development')
    end

    def root
      config.root
    end

    def logger_path
      @logger_path ||= Bobcat.root.join("log/#{Bobcat.env}.log")
    end

    def logger
      return @logger if @logger
      @logger = Logger.new(Bobcat.root.join("log/#{Bobcat.env}.log"))
      @logger.formatter = proc { |severity, timestamp, progname, msg| "#{timestamp.iso8601} #{severity} #{msg} \n" }
      @logger
    end

    def cache
      config.cache_store
    end
  end
end
