require "rails_helper"

RSpec.describe "Robots", type: :request do
  describe "GET /robots.txt" do
    let(:production_host) { "www.getbenefitshelp.org" }
    let(:non_production_host) { "staging.getbenefitshelp.org" }

    context "when on production host" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        host! production_host

        get "/robots.txt"
      end

      it "allows crawling and includes sitemap" do
        expect(response).to have_http_status(:ok)

        expect(response.body).to eq(<<~TXT)
          User-agent: *
          Allow: /
          Sitemap: https://getbenefitshelp.org/sitemap.xml
        TXT
      end
    end

    context "when on non-production host" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true) # still production env, but wrong host
        host! non_production_host

        get "/robots.txt"
      end

      it "disallows crawling" do
        expect(response).to have_http_status(:ok)

        expect(response.body).to eq(<<~TXT)
          User-agent: *
          Disallow: /
        TXT
      end
    end
  end
end
