require "rails_helper"

RSpec.describe "400 Bad Request error page", type: :request do
  describe "GET /400" do
    it "returns HTTP 400" do
      get "/400"
      expect(response).to have_http_status(:bad_request)
    end

    context "in English (default)" do
      before { get "/400" }

      it_behaves_like "an error page", :en

      it "shows the error badge" do
        expect(response.body).to include("ERROR: 400 Bad Request")
      end
    end

    context "in Spanish (locale=es)" do
      before { get "/400", params: {locale: "es"} }

      it_behaves_like "an error page", :es

      it "returns HTTP 400" do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "exception triggering" do
    it "returns HTTP 400 when query parameters have conflicting types" do
      get "/en/location?screener=bad&screener[state]=NC"
      expect(response).to have_http_status(:bad_request)
    end
  end
end
