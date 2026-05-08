require "rails_helper"

RSpec.describe "Robots", type: :request do
  describe "GET /robots.txt" do
    context "in production" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        get "/robots.txt"
      end

      it "allows all crawling and includes sitemap" do
        expect(response).to have_http_status(:ok)

        expect(response.body).to eq(<<~TXT)
          User-agent: *
          Allow: /
          Sitemap: https://getbenefitshelp.org/sitemap.xml
        TXT
      end
    end

    context "in non-production" do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
        get "/robots.txt"
      end

      it "disallows all crawling" do
        expect(response).to have_http_status(:ok)

        expect(response.body).to eq(<<~TXT)
          User-agent: *
          Disallow: /
        TXT
      end
    end
  end
end
