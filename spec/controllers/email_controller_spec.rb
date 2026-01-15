require "rails_helper"

RSpec.describe EmailController, type: :controller do
  describe "#update" do
    it "saves the email regardless of white spaces or capitalization" do
      screener = create(:screener)

      params = {
        email: "anisHa@codeforamerica.org ",
        email_confirmation: " anisha@codeforamerica.org"
      }

      post :update, params: {screener: params}
      expect(response).to redirect_to subject.next_path
      expect(screener.reload.email).to eq "anisha@codeforamerica.org"
    end
  end
end
