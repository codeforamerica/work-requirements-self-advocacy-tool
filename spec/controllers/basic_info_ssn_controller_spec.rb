require "rails_helper"

RSpec.describe BasicInfoSsnController, type: :controller do
  describe "#update" do
    it "saves the last 4 digits of the ssn and redirects to the next step" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {ssn_last_four: "4567"}}

      expect(response).to redirect_to subject.next_path
      expect(screener.reload.ssn_last_four).to eq "4567"
    end
  end
end
