require "rails_helper"

RSpec.describe "security headers", type: :request do
  describe "Permissions-Policy" do
    it "is set on a normal page" do
      get "/"
      expect(response.headers["Permissions-Policy"]).to be_present
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
