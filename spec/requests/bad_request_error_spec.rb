require "rails_helper"

RSpec.describe "400 Bad Request error page", type: :request do
  describe "GET /400" do
    it "returns HTTP 400" do
      get "/400"
      expect(response).to have_http_status(:bad_request)
    end

    context "in English (default)" do
      before { get "/400" }

      it "shows the English title" do
        expect(response.body).to include("The page couldn")
      end

      it "shows the error badge" do
        expect(response.body).to include("ERROR: 400 Bad Request")
      end

      it "shows the English description" do
        expect(response.body).to include("We")
        expect(response.body).to include("experiencing a temporary issue")
      end

      it "shows the contact email as a mailto link" do
        expect(response.body).to include('href="mailto:getbenefitshelp@codeforamerica.org"')
      end

      it "shows the English CTA" do
        expect(response.body).to include("Go to home page")
      end
    end

    context "in Spanish (locale=es)" do
      before { get "/400", params: {locale: "es"} }

      it "returns HTTP 400" do
        expect(response).to have_http_status(:bad_request)
      end

      it "shows the Spanish title" do
        expect(response.body).to include("No pudimos cargar esta p")
      end

      it "shows the Spanish description" do
        expect(response.body).to include("Estamos experimentando un problema temporal")
      end

      it "shows the Spanish CTA" do
        expect(response.body).to include("Volver al inicio")
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
