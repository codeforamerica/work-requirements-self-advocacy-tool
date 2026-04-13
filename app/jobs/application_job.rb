class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Make sure to capture and record any exceptions that occur in jobs.
  # Uses around_perform rather than rescue_from so that the OTel span is still
  # open when we annotate it — rescue_from runs after the instrumentation has
  # already ended the span.
  around_perform do |_job, block|
    block.call
  rescue Exception => error # standard:disable Lint/RescueException
    span = OpenTelemetry::Trace.current_span
    span.status = OpenTelemetry::Trace::Status.error("Job failed")
    span.set_attribute("job.class", self.class.name)
    span.set_attribute("job.id", job_id)
    span.record_exception(error)

    Rails.logger.error(
      "Job failed",
      {job_class: self.class.name, job_id: job_id},
      error
    )

    raise
  end
end
