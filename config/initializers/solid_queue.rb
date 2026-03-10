# frozen_string_literal: true

ActiveSupport::Notifications.subscribe("polling.solid_queue") do
  OpenTelemetry::Trace.current_span.set_attribute("polling.solid_queue", "true")
end

