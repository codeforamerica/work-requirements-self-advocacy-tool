require "rails_helper"

RSpec.describe "400 Bad Request error page", type: :request do
  context "GET /400 in English" do
    before { get "/400" }

    it_behaves_like "an error page", :en

    it "returns HTTP 400" do
      expect(response).to have_http_status(:bad_request)
    end

    it "shows the error badge" do
      expect(response.body).to include("ERROR: 400 Bad Request")
    end
  end

  context "GET /400 in Spanish" do
    before { get "/400", params: {locale: "es"} }

    it_behaves_like "an error page", :es

    it "returns HTTP 400" do
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "exception triggering" do
    it "returns HTTP 400 when query parameters have conflicting types" do
      get "/en/location?screener=bad&screener[state]=NC"
      expect(response).to have_http_status(:bad_request)
    end
  end
end
