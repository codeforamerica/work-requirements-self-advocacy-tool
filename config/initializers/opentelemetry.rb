# frozen_string_literal: true

require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  # These are useful for filtering.
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "getbenefitshelp-web")
  c.service_version = ENV["APP_VERSION"] if ENV["APP_VERSION"].present?

  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    "deployment.environment" => Rails.env.to_s,
    "service.namespace" => "getbenefitshelp"
  )

  # Instrument all supported libraries.
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
