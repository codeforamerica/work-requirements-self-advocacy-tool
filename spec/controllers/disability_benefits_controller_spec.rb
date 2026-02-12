require "rails_helper"

RSpec.describe DisabilityBenefitsController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        receiving_benefits_ssdi: "no",
        receiving_benefits_ssi: "yes",
        receiving_benefits_veterans_disability: "no",
        receiving_benefits_disability_pension: "no",
        receiving_benefits_workers_compensation: "no",
        receiving_benefits_insurance_payments: "no",
        receiving_benefits_disability_medicaid: "yes",
        receiving_benefits_other: "yes",
        receiving_benefits_none: "no",
        receiving_benefits_write_in: "boop"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.receiving_benefits_ssdi).to eq "no"
      expect(screener.receiving_benefits_ssi).to eq "yes"
      expect(screener.receiving_benefits_veterans_disability).to eq "no"
      expect(screener.receiving_benefits_disability_pension).to eq "no"
      expect(screener.receiving_benefits_workers_compensation).to eq "no"
      expect(screener.receiving_benefits_insurance_payments).to eq "no"
      expect(screener.receiving_benefits_disability_medicaid).to eq "yes"
      expect(screener.receiving_benefits_other).to eq "yes"
      expect(screener.receiving_benefits_none).to eq "no"
      expect(screener.receiving_benefits_write_in).to eq "boop"
    end
  end
end
