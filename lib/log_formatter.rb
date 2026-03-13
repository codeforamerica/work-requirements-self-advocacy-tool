# frozen_string_literal: true

# Custom log formatter for Rails Semantic Logger.
#
# We use this instead of the default JSON formatter so that we can add
# additional attributes to the log for correlation.
class LogFormatter < SemanticLogger::Formatters::Raw
  AWS_RESOURCE_ATTRIBUTES = {
    "aws.ecs.task.arn" => :task_arn,
    "aws.ecs.cluster.arn" => :cluster_arn,
    "aws.ecs.task.family" => :task_family,
    "aws.ecs.task.revision" => :task_revision
  }.freeze

  def call(log, logger)
    super

    current_trace
    resource
    screener_id
    service
    session_id

    hash.to_json
  end

  private

  # Add the current trace and span IDs, if any, to the attributes.
  def current_trace
    hash[:span_id] = log.context[:span_id] if log.context[:span_id].present?
    hash[:trace_id] = log.context[:trace_id] if log.context[:trace_id].present?
  end

  # Add the AWS resource details to the attributes.
  def resource
    hash.merge!(resource_attrs)
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
    hash[:screener_id] = log.context[:screener_id] if log.context[:screener_id].present?
  end

  # Add the service name to the attributes.
  def service
    hash[:service] = ENV.fetch("OTEL_SERVICE_NAME", "getbenefitshelp-web")
  end

  # Add the session ID to the attributes.
  def session_id
    hash[:session_id] = log.context[:session_id] if log.context[:session_id].present?
  end
end
