require "rails_helper"

RSpec.describe BasicInfoEmailController, type: :controller do
  describe "#update" do
    let(:screener) { create(:screener) }

    before do
      sign_in screener
    end

    it "saves the email regardless of white spaces or capitalization" do
      params = {
        email: "anisHa@codeforamerica.org ",
        email_confirmation: " anisha@codeforamerica.org"
      }

      post :update, params: {screener: params}
      expect(response).to redirect_to subject.next_path
      expect(screener.reload.email).to eq "anisha@codeforamerica.org"
    end

    # TODO: move this to the signature page once it exists
    it "adds the confirmation code" do
      expect(screener.confirmation_code).to be_nil

      post :update, params: {screener: {email: "boop@example.com ", email_confirmation: "boop@example.com"}}

      expect(screener.reload.confirmation_code).to be_present
    end
  end
end
