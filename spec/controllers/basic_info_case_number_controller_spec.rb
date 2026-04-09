require "rails_helper"

RSpec.describe BasicInfoCaseNumberController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "saves the case number and redirects to the next step" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {case_number: "ABC-123"}}

      expect(response).to redirect_to subject.next_path
      expect(screener.reload.case_number).to eq "ABC-123"
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end
