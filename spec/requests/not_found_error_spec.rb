require "rails_helper"

RSpec.describe "404 Not Found error page", type: :request do
  describe "GET /404" do
    it "returns HTTP 404" do
      get "/404"
      expect(response).to have_http_status(:not_found)
    end

    context "in English (default)" do
      before { get "/404" }

      it_behaves_like "an error page in English"

      it "shows the English title" do
        expect(response.body).to include("The page couldn")
      end

      it "shows the error badge" do
        expect(response.body).to include("ERROR: 404 Not Found")
      end

      it "shows the English description" do
        expect(response.body).to include("The link you followed may be broken or outdated")
      end
    end

    context "in Spanish (locale=es)" do
      before { get "/404", params: {locale: "es"} }

      it_behaves_like "an error page in Spanish"

      it "returns HTTP 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "shows the Spanish title" do
        expect(response.body).to include("No pudimos encontrar esta p")
      end

      it "shows the Spanish description" do
        expect(response.body).to include("La página a la que intenta acceder")
      end
    end
  end
end
