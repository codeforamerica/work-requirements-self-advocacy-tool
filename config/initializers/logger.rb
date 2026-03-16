# frozen_string_literal: true

require Rails.root.join("lib", "log_formatter")

Rails.application.configure do
  # Setup structured logging.
  config.semantic_logger.application = "getbenefitshelp"
  config.semantic_logger.environment = Rails.env

  config.rails_semantic_logger.add_file_appender = false
  config.semantic_logger.add_appender(io: $stdout, formatter: LogFormatter.new)

  # Use the `on_log` callback to set attributes that we want to include in all
  # logs, but need to be set in the same fiber as the caller.
  config.semantic_logger.on_log do |log|
    log.set_context(:session_id, RequestStore[:session_id]) unless RequestStore[:session_id].blank?
    log.set_context(:screener_id, RequestStore[:screener_id]) unless RequestStore[:screener_id].blank?

    span = OpenTelemetry::Trace.current_span
    if span.recording?
      log.set_context(:trace_id, span.context.hex_trace_id) unless span.context.trace_id == 0
      log.set_context(:span_id, span.context.hex_span_id) unless span.context.span_id == 0
    elsif RequestStore[:trace_id].present?
      log.set_context(:trace_id, RequestStore[:trace_id]) unless RequestStore[:trace_id].blank?
      log.set_context(:span_id, RequestStore[:span_id]) unless RequestStore[:span_id].blank?
    end
  end
end
