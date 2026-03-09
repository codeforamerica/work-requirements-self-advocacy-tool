# frozen_string_literal: true

# Add attributes to the current span for the queue polling event so that we can
# identity and potentially filter these events.
ActiveSupport::Notifications.subscribe("polling.solid_queue") do
  OpenTelemetry::Trace.current_span.add_attributes({
    "polling.solid_queue" => "true"
  })
end
