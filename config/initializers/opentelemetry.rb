require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  # These are useful for Datadog filtering
  resource_attributes = {
    "service.name" => "getbenefitshelp",
    "deployment.environment" => Rails.env.to_s
  }

  if ENV["APP_VERSION"].present?
    resource_attributes["service.version"] = ENV["APP_VERSION"]
  end

  c.resource = OpenTelemetry::SDK::Resources::Resource.create(resource_attributes)

  # Instrument all supported libraries
  c.use_all

  # Only export traces if an endpoint has been configured
  if ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].present?
    require "opentelemetry/exporter/otlp"
    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new
      )
    )
  end
end
