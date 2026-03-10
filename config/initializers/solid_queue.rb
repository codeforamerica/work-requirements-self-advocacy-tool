# frozen_string_literal: true

ActiveSupport::Notifications.subscribe("polling.solid_queue") do |_name, start, finish, _id, _payload|
  tracer = OpenTelemetry.tracer_provider.tracer("solid_queue")
  span = tracer.start_span(
    "polling solid_queue",
    attributes: {"polling.solid_queue" => "true"},
    start_timestamp: start
  )
  span.finish(end_timestamp: finish)
end
