require 'active_record'

module Bobcat
  module Components
    module ActiveRecord
      def invoke_service(m, *args)
        super
      ensure
        # 回收当前线程所使用的连接到连接池
        ::ActiveRecord::Base.clear_active_connections!
      end

      # LazyLoadHooks
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.default_timezone               = :local
        ::ActiveRecord::Base.raise_in_transaction_callbacks = true

        config_file = Bobcat.root.join('config', 'database.yml')
        database_config = YAML.load_file(config_file)[Bobcat.env]
        ::ActiveRecord::Base.establish_connection(database_config)
      end
    end
  end
end