require "rails_helper"

RSpec.describe PreventingWorkReasonController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        preventing_work_place_to_sleep: "yes",
        preventing_work_drugs_alcohol: "no",
        preventing_work_domestic_violence: "yes",
        preventing_work_medical_condition: "no",
        preventing_work_other: "yes",
        preventing_work_none: "no",
        preventing_work_write_in: "boop"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.preventing_work_place_to_sleep).to eq "yes"
      expect(screener.preventing_work_drugs_alcohol).to eq "no"
      expect(screener.preventing_work_domestic_violence).to eq "yes"
      expect(screener.preventing_work_medical_condition).to eq "no"
      expect(screener.preventing_work_other).to eq "yes"
      expect(screener.preventing_work_none).to eq "no"
      expect(screener.preventing_work_write_in).to eq "boop"
    end
  end
end
