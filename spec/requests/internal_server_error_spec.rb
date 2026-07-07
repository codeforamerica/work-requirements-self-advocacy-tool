require "rails_helper"

RSpec.describe "500 Internal Server Error page", type: :request do
  describe "GET /500" do
    it "returns HTTP 200 on direct visit" do
      get "/500"
      expect(response).to have_http_status(:ok)
    end

    context "in English (default)" do
      before { get "/500" }

      it_behaves_like "an error page in English"

      it "shows the English title" do
        expect(response.body).to include("The page couldn")
      end

      it "shows the error badge" do
        expect(response.body).to include("ERROR: 500 Internal Server Error")
      end

      it "shows the English description" do
        expect(response.body).to include("experiencing a temporary issue")
      end
    end

    context "in Spanish (locale=es)" do
      before { get "/500", params: {locale: "es"} }

      it_behaves_like "an error page in Spanish"

      it "returns HTTP 200 on direct visit" do
        expect(response).to have_http_status(:ok)
      end

      it "shows the Spanish title" do
        expect(response.body).to include("No pudimos cargar esta p")
      end

      it "shows the Spanish description" do
        expect(response.body).to include("Estamos experimentando un problema temporal")
      end
    end
  end
end
