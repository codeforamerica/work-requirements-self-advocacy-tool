ActiveSupport.on_load(:action_mailer) do
  RailsSemanticLogger::ActionMailer::LogSubscriber.prepend(Module.new do
    def deliver(event)
      event.payload[:to] = Array(event.payload[:to]).map { "[email redacted]" }

      if (exc = event.payload[:exception_object])
        sanitized = exc.message.gsub(/[\w.+-]+@[\w.-]+\.\w+/, "[email redacted]")
        event.payload[:exception_object] = exc.exception(sanitized)
        if exc.is_a?(Aws::SESV2::Errors::AccessDeniedException)
          log_with_formatter event: event, log_duration: true, level: :warn do |_fmt|
            {
              message: "Error delivering mail #{event.payload[:message_id]} (#{event.duration.round(1)}ms)",
              exception: event.payload[:exception_object]
            }
          end
          return
        end
      end
      super
    end
  end)
end
