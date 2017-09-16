module Bobcat
  class LogSubscrber < ::ActiveSupport::LogSubscriber
    def process_hook_method(event)
      payload = event.payload

      info "#{payload[:uuid]} Processing #{ENV['APP_NAME']}##{payload[:method]} in #{event.duration}ms"
      info "#{payload[:uuid]}   Args: #{payload[:args]}" unless payload[:args]
    end

    private

    def logger
      Bobcat.logger
    end
  end
end

Bobcat::LogSubscriber.attach_to :bobcat