# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    span = OpenTelemetry::Trace.current_span
    context = span.context

    {
      time: event.time,
      method: event.payload[:method],
      path: event.payload[:path],
      status: event.payload[:status],
      screener_id: event.payload[:screener]&.id,
      session_id: event.payload[:session_id],

      # Use context.hex_trace_id / hex_span_id if trace_id is valid
      trace_id: (context.trace_id != 0) ? context.hex_trace_id : nil,
      span_id: (context.span_id != 0) ? context.hex_span_id : nil
    }
  end
end
