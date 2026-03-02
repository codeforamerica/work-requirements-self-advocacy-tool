require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "gbh-ruby"

  # These are useful for Datadog filtering
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    "deployment.environment" => Rails.env,
    "service.version" => ENV["GIT_SHA"]
  )

  # Instrument all supported libraries
  c.use_all

  # Only export traces if not in development
  unless Rails.env.development?
    require "opentelemetry/exporter/otlp"

    otlp_endpoint = ENV.fetch("OTEL_EXPORTER_OTLP_ENDPOINT", "https://otlp.datadoghq.com/v1/traces")
    datadog_api_key = ENV.fetch("DATADOG_API_KEY")

    c.add_span_processor(
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        OpenTelemetry::Exporter::OTLP::Exporter.new(
          endpoint: otlp_endpoint,
          headers: {"DD-API-KEY" => datadog_api_key}
        )
      )
    )
  end
end
