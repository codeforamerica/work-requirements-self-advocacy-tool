Rails.application.configure do
  config.lograge.enabled = true
  config.colorize_logging = false
  config.lograge.keep_original_rails_log = false

  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:headers]&.[]("action_dispatch.request_id"),
      session_id: RequestStore.store[:session_id],
      screener_id: RequestStore.store[:screener_id],
      level: event.payload[:level] || "INFO",
      time: Time.now.utc.iso8601(3),
      trace_id: OpenTelemetry::Trace.current_span.context.hex
    }.compact
  end
end
