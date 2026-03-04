require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "getbenefitshelp"

  # These are useful for Datadog filtering
  resource_attributes = {
    "deployment.environment" => Rails.env
  }

  if ENV["APP_VERSION"].present?
    resource_attributes["service.version"] = ENV["APP_VERSION"]
  end

  c.resource = OpenTelemetry::SDK::Resources::Resource.create(resource_attributes)

  # Instrument all supported libraries
  c.use_all

  # Only export traces if an endpoint has been configured
  otlp_endpoint = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]

  if otlp_endpoint.present?
    require "opentelemetry/exporter/otlp"
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new(
          endpoint: otlp_endpoint
        )
      )
    )
  end
end
