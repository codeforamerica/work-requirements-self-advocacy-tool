require "rails_helper"

RSpec.describe CaringForSomeoneController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        caring_for_child_under_6: "yes",
        caring_for_disabled_or_ill_person: "yes",
        caring_for_no_one: "no",
        additional_care_info: "lots of care"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.caring_for_child_under_6).to eq "yes"
      expect(screener.caring_for_disabled_or_ill_person).to eq "yes"
      expect(screener.caring_for_no_one).to eq "no"
      expect(screener.additional_care_info).to eq "lots of care"
    end
  end
end
