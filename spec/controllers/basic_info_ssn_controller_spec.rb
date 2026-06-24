require "rails_helper"

RSpec.describe BasicInfoSsnController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) { [{form_params: {ssn_last_four: "4567"}, expected_data: {has_ssn_last_four: true}}] }
      let(:invalid_params) { {ssn_last_four: "abc"} }
    end

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
