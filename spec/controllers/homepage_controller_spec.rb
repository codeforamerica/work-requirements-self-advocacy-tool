require "rails_helper"

RSpec.describe HomepageController, type: :controller do
  describe "#redirect_without_source" do
    it "redirects to the base path with the source as a query param" do
      get :redirect_without_source, params: {base_path: "en", intended_source: "fancysource"}

      expect(response).to redirect_to("/en?source=fancysource")
    end

    it "redirects to root when base_path is absent" do
      get :redirect_without_source, params: {intended_source: "fancysource"}

      expect(response).to redirect_to("/?source=fancysource")
    end

    it "does not raise a 500 when intended_source contains URI-unsafe characters" do
      get :redirect_without_source, params: {base_path: "en", intended_source: "\#{7_7}"}

      expect(response).to have_http_status(:redirect)
    end

    it "does not raise a 500 when base_path contains URI-unsafe characters" do
      get :redirect_without_source, params: {base_path: "{bad}", intended_source: "test"}

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "#create_screener" do
    it "creates a new screener and puts the id in the session" do
      visitor_id = "BEEPBEEPBEEP"
      source = "BOOPBOOPBOOP"
      cookies.encrypted[:visitor_id] = visitor_id
      session[:source] = source

      expect {
        get :create_screener
      }.to change(Screener, :count).by(1)

      screener = Screener.last
      expect(screener.visitor_id).to eq visitor_id
      expect(screener.source).to eq source
      expect(response).to redirect_to Navigation::ScreenerNavigation.first.to_path_helper
    end
  end
end
