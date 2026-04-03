class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Make sure to capture and record any exceptions that occur in jobs.
  rescue_from(Exception) do |error|
    span = OpenTelemetry::Trace.current_span
    span.status = OpenTelemetry::Trace::Status.error(error.message)
    span.record_exception(
      error,
      attributes: {"job.class" => self.class.name, "job.id" => job_id}
    )

    Rails.logger.error("Job failed", job_class: self.class.name, job_id: job_id,
      error: error.message, error_class: error.class.name,
      backtrace: error.backtrace&.first(5))

    # Re-raise the exception to be handled by the job framework (SolidQueue).
    raise error
  end
end
