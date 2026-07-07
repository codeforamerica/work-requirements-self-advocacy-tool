require "rails_helper"

RSpec.describe "404 Not Found error page", type: :request do
  describe "GET /404" do
    it "returns HTTP 404" do
      get "/404"
      expect(response).to have_http_status(:not_found)
    end

    context "in English (default)" do
      before { get "/404" }

      it_behaves_like "an error page", :en

      it "shows the error badge" do
        expect(response.body).to include("ERROR: 404 Not Found")
      end
    end

    context "in Spanish (locale=es)" do
      before { get "/404", params: {locale: "es"} }

      it_behaves_like "an error page", :es

      it "returns HTTP 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
