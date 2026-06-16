# frozen_string_literal: true

require Rails.root.join("lib", "log_formatter")

# Omit request params and error messages from AWS SDK logs — both can contain
# email addresses and full message bodies.
Aws.config[:log_formatter] = Aws::Log::Formatter.new(
  "[:client_class :http_response_status_code :retries retries :time] :operation :error_class"
)

Rails.application.configure do
  # Setup structured logging.
  config.semantic_logger.application = "getbenefitshelp"
  config.semantic_logger.environment = Rails.env

  config.rails_semantic_logger.add_file_appender = false
  config.semantic_logger.add_appender(io: $stdout, formatter: LogFormatter.new)

  # Recursively redact email addresses from any string, array, or hash value.
  REDACT_EMAILS = lambda do |value|
    case value
    when String then value.gsub(/[\w.+\-]+@[\w.\-]+\.\w+/, "[email redacted]")
    when Array  then value.map { |v| REDACT_EMAILS.call(v) }
    when Hash   then value.transform_values { |v| REDACT_EMAILS.call(v) }
    else value
    end
  end

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

    log.message = REDACT_EMAILS.call(log.message) if log.message.present?
    log.payload = REDACT_EMAILS.call(log.payload) if log.payload.is_a?(Hash)
    if log.exception
      log.exception = log.exception.exception(REDACT_EMAILS.call(log.exception.message))
      log.level = :warn if log.exception.is_a?(Aws::SESV2::Errors::AccessDeniedException)
    end
  end
end
