require "rails_helper"

RSpec.describe "security headers", type: :request do
  describe "Permissions-Policy" do
    it "is set on a normal page" do
      get "/"
      expect(response.headers["Permissions-Policy"]).to be_present
    end
  end

  describe "CSP reporting" do
    it "includes a report-to directive naming the csp-endpoint group" do
      get "/"
      expect(response.headers["Content-Security-Policy"]).to match(/report-to csp-endpoint/)
    end

    it "includes a report-uri directive as a legacy fallback" do
      get "/"
      expect(response.headers["Content-Security-Policy"]).to match(%r{report-uri /csp_reports})
    end

    it "sets a Reporting-Endpoints header naming the csp-endpoint group" do
      get "/"
      expect(response.headers["Reporting-Endpoints"]).to eq('csp-endpoint="/csp_reports"')
    end
  end

  describe "POST /csp_reports" do
    before { allow(Rails.logger).to receive(:warn).and_call_original }

    it "accepts a legacy report-uri style report and returns 204" do
      post "/csp_reports", params: {"csp-report" => {"violated-directive" => "script-src", "blocked-uri" => "https://evil.example", "unexpected-field" => "some raw user-submitted PII"}}.to_json,
        headers: {"CONTENT_TYPE" => "application/json"}
      expect(response).to have_http_status(:no_content)
      expect(Rails.logger).to have_received(:warn).with("CSP violation: directive=script-src blocked_uri=https://evil.example document_uri=")
    end

    it "accepts a report-to style Reporting API report and returns 204" do
      body = [{"type" => "csp-violation", "body" => {"effectiveDirective" => "script-src", "blockedURL" => "https://evil.example", "documentURL" => "https://www.getbenefitshelp.org/"}}]
      post "/csp_reports", params: body.to_json, headers: {"CONTENT_TYPE" => "application/reports+json"}
      expect(response).to have_http_status(:no_content)
      expect(Rails.logger).to have_received(:warn).with("CSP violation: directive=script-src blocked_uri=https://evil.example document_uri=https://www.getbenefitshelp.org/")
    end

    it "does not log the raw request body" do
      post "/csp_reports", params: {"csp-report" => {"violated-directive" => "script-src", "unexpected-field" => "some raw user-submitted PII"}}.to_json,
        headers: {"CONTENT_TYPE" => "application/json"}
      expect(Rails.logger).not_to have_received(:warn).with(/PII/)
    end

    it "returns 204 without raising on malformed JSON" do
      post "/csp_reports", params: "not json", headers: {"CONTENT_TYPE" => "application/json"}
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "GET /.well-known/security.txt" do
    it "returns a contact line" do
      get "/.well-known/security.txt"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Contact: mailto:getbenefitshelp@codeforamerica.org")
    end
  end
end
