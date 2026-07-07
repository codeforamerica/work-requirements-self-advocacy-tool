require "rails_helper"

RSpec.describe "500 Internal Server Error page", type: :request do
  describe "GET /500" do
    it "returns HTTP 200 on direct visit" do
      get "/500"
      expect(response).to have_http_status(:ok)
    end

    context "in English (default)" do
      before { get "/500" }

      it_behaves_like "an error page", :en

      it "shows the error badge" do
        expect(response.body).to include("ERROR: 500 Internal Server Error")
      end
    end

    context "in Spanish (locale=es)" do
      before { get "/500", params: {locale: "es"} }

      it_behaves_like "an error page", :es

      it "returns HTTP 200 on direct visit" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
