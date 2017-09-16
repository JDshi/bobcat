module Bobcat
  module Server
    class Handler

      def initialize(server_klass)
        @server_klass = server_klass
        # 为handle实例定义单例方法，用于执行application的方法
        @server_klass.service_method.each do |method|
          define_singleton_method(method) do |*args|
            # 通过钩子方法执行application的方法，用于记录方法请求的日志信息
            @server_klass.new.hook_method(m, *args)
          end
        end
      end
    end
  end
end