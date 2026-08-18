require "rails_helper"

RSpec.describe LogFormatter do
  subject(:formatter) { described_class.new }

  # LogFormatter#call expects a subscriber/appender (not a Logger) as its second
  # argument -- that's what supplies #host, #application, and #environment.
  let(:appender) { SemanticLogger::Appender::IO.new(StringIO.new, formatter: formatter) }

  def build_log(context: nil)
    log = SemanticLogger::Log.new("TestLogger", :info)
    log.context = context
    log.assign(message: "hello")
    log
  end

  def formatted(context: nil)
    JSON.parse(formatter.call(build_log(context: context), appender))
  end

  it "does not crash on log entries with no request/job context" do
    expect { formatted(context: nil) }.not_to raise_error
  end

  it "omits span_id, trace_id, screener_id, and session_id when there is no context" do
    result = formatted(context: nil)

    expect(result).not_to have_key("span_id")
    expect(result).not_to have_key("trace_id")
    expect(result).not_to have_key("screener_id")
    expect(result).not_to have_key("session_id")
  end

  it "includes the trace and span IDs from the log context" do
    result = formatted(context: {span_id: "span-123", trace_id: "trace-456"})

    expect(result["span_id"]).to eq("span-123")
    expect(result["trace_id"]).to eq("trace-456")
  end

  it "includes the screener ID from the log context" do
    result = formatted(context: {screener_id: "screener-123"})

    expect(result["screener_id"]).to eq("screener-123")
  end

  it "includes the session ID from the log context" do
    result = formatted(context: {session_id: "session-123"})

    expect(result["session_id"]).to eq("session-123")
  end

  it "includes the configured service name" do
    result = formatted(context: nil)

    expect(result["service"]).to eq(ENV.fetch("OTEL_SERVICE_NAME", "getbenefitshelp-web"))
  end

  it "does not mutate the log entry's context" do
    log = build_log(context: nil)

    formatter.call(log, appender)

    expect(log.context).to be_nil
  end
end
