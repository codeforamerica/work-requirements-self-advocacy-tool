class CspReportsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # Browsers send reports in one of two shapes depending on whether they used the
  # legacy report-uri directive or the newer Reporting API (report-to):
  # - report-uri:  {"csp-report" => {"violated-directive" => ..., "blocked-uri" => ..., "document-uri" => ...}}
  # - report-to:   [{"body" => {"effectiveDirective" => ..., "blockedURL" => ..., "documentURL" => ...}}]
  # Logging only these known fields (rather than the raw body) avoids persisting
  # arbitrary client-submitted content, since this endpoint is public and unauthenticated.
  def create
    payload = JSON.parse(request.body.read)
    report = payload.is_a?(Array) ? payload.first&.fetch("body", {}) : payload["csp-report"]
    report ||= {}

    Rails.logger.warn(
      "CSP violation: directive=#{report["violated-directive"] || report["effectiveDirective"]} " \
      "blocked_uri=#{report["blocked-uri"] || report["blockedURL"]} " \
      "document_uri=#{report["document-uri"] || report["documentURL"]}"
    )
  rescue JSON::ParserError
    Rails.logger.warn("CSP violation: unparseable report")
  ensure
    head :no_content
  end
end
