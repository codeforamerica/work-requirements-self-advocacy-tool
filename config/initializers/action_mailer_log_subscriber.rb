ActiveSupport.on_load(:action_mailer) do
  ActionMailer::LogSubscriber.prepend(Module.new do
    def deliver(event)
      event.payload[:to] = Array(event.payload[:to]).map { "[email redacted]" }

      if (exc = event.payload[:exception_object])
        sanitized = exc.message.gsub(/[\w.+-]+@[\w.-]+\.\w+/, "[email redacted]")
        if exc.is_a?(Aws::SESV2::Errors::AccessDeniedException)
          warn { "Error delivering mail #{event.payload[:message_id]}: #{sanitized}" }
          return
        end
        event.payload[:exception_object] = exc.exception(sanitized)
      end
      super
    end
  end)
end
