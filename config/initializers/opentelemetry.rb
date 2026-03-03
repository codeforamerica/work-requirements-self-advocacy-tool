require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "getbenefitshelp"

  # These are useful for Datadog filtering
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    "deployment.environment" => Rails.env,
    "service.version" => ENV["APP_VERSION"]
  )

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
