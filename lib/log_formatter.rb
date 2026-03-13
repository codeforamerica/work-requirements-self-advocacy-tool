# frozen_string_literal: true

# Custom log formatter for Rails Semantic Logger.
#
# We use this instead of the default JSON formatter so that we can add
# additional attributes to the log for correlation.
class LogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super

    hash.merge!(resource_attrs)
    current_trace
    screener_id
    session_id

    hash.to_json
  end

  private

  # Add the current trace and span IDs to the attributes.
  def current_trace
    span = OpenTelemetry::Trace.current_span
    hash[:span_id] = span.context.hex_span_id if span.context.span_id != 0
    hash[:trace_id] = span.context.hex_trace_id if span.context.trace_id != 0
  end

  # Retrieve AWS resource attributes to the attributes.
  #
  # @return [Hash] the AWS resource attributes.
  def resource_attrs
    @resource_attrs ||= begin
      resource = OpenTelemetry::Resource::Detector::AWS.detect([:ecs, :eks])
      resource.attribute_enumerator.to_h
    end
  end

  # Add the screener ID to the attributes.
  def screener_id
    hash[:screener_id] = log.payload[:screener]&.id
  end

  # Add the session ID to the attributes.
  def session_id
    hash[:session_id] = log.payload[:session_id]
  end
end
