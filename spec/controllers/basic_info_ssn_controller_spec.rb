require "rails_helper"

RSpec.describe BasicInfoSsnController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit


    it "saves the last 4 digits of the ssn and redirects to the next step" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {ssn_last_four: "4567"}}

      expect(response).to redirect_to subject.next_path
      expect(screener.reload.ssn_last_four).to eq "4567"
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end
