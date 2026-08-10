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
    it "accepts a violation report and returns 204" do
      post "/csp_reports", params: {"csp-report" => {"violated-directive" => "script-src"}}.to_json,
        headers: {"CONTENT_TYPE" => "application/json"}
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
