module Bobcat
  class Config
    include ActiveSupport::Configurable

    def initialize
      default_config!
    end

    def default_config!
      config.app_name       = 'bobcat'
      config.cache_store    = [:memory_store]
      config.root           = Pathname.pwd
      config.bingding       = '127.0.0.1'
      config.port           = '8888'
      config.thrift_threads = 5
    end
  end
end