require "rails_helper"

RSpec.describe CaringForSomeoneController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

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
