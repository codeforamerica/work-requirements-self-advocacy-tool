require "rails_helper"

RSpec.describe HomepageController, type: :controller do
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
