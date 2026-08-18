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

  context "GET an unmatched path" do
    before { get "/this_path_does_not_exist" }

    it "returns HTTP 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "still sets a Content-Security-Policy header" do
      expect(response.headers["Content-Security-Policy"]).to be_present
    end
  end

  context "GET a locale path with unexpected casing" do
    # The locale scope's regex match is case-sensitive, so e.g. /ES/start_flow doesn't
    # match any route and previously fell into the same missing-CSP gap as any other
    # unmatched path.
    before { get "/ES/start_flow" }

    it "returns HTTP 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "still sets a Content-Security-Policy header" do
      expect(response.headers["Content-Security-Policy"]).to be_present
    end
  end

  context "GET an unmatched path with a non-html extension" do
    # The catch-all route matches any unmatched path, so a request for a nonexistent
    # "*.css" (or similar) asset resolves its format from the extension. We only have
    # html templates, so this previously raised ActionView::MissingTemplate instead of
    # rendering a normal 404.
    before { get "/this_path_does_not_exist.css" }

    it "returns HTTP 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "renders the html error page" do
      expect(response.body).to include("ERROR: 404 Not Found")
    end
  end
end
