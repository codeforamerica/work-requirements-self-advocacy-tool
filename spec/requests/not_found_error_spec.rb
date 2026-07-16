require "rails_helper"

RSpec.describe "404 Not Found error page", type: :request do
  context "GET /404 in English" do
    before { get "/404" }

    it_behaves_like "an error page", :en

    it "returns HTTP 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "shows the error badge" do
      expect(response.body).to include("ERROR: 404 Not Found")
    end
  end

  context "GET /404 in Spanish" do
    before { get "/404", params: {locale: "es"} }

    it_behaves_like "an error page", :es

    it "returns HTTP 404" do
      expect(response).to have_http_status(:not_found)
    end
  end
end
