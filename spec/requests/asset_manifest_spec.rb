require "rails_helper"

RSpec.describe "asset manifest security", type: :request do
  describe "GET /assets/.manifest.json" do
    it "returns 404 to prevent asset enumeration" do
      get "/assets/.manifest.json"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "non-manifest paths" do
    it "passes through normally" do
      get "/up"
      expect(response).not_to have_http_status(:not_found)
    end
  end
end
