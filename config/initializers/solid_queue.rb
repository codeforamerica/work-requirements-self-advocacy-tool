# frozen_string_literal: true

# Surface SolidQueue thread-level errors (worker/dispatcher crashes) to logs and
# traces. Job-level errors are handled in ApplicationJob#rescue_from.
SolidQueue.on_thread_error = lambda do |error|
  span = OpenTelemetry::Trace.current_span
  span.status = OpenTelemetry::Trace::Status.error("SolidQueue thread error")
  span.record_exception(error)

  Rails.logger.error("SolidQueue thread error", error)
end
