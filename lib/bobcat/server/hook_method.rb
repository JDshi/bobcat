module Bobcat
  module Server
    module HookMethod
      def hook_method(m, *args)
        payload = {method: m, args: args, uuid: SecureRandom.uuid}

        ActiveSupport::Notifications.instrument('process_hook_method.bobcat', payload) do
          super
        end
      rescue Exception => e
        ::Bugsnag.notify(e) if defined?(Bugsnag)
        Tservice.logger.warn("#{payload[:uuid]} Exception: #{e.inspect}")
        Tservice.logger.warn(e.backtrace.join("\n"))
        raise e

        __send__(m, *args)
      end
    end
  end
end
