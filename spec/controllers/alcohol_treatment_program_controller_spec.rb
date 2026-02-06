require "rails_helper"

RSpec.describe AlcoholTreatmentProgramController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        is_in_alcohol_treatment_program: "yes",
        alcohol_treatment_program_name: "Prog Ram"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.is_in_alcohol_treatment_program_yes?).to eq true
      expect(screener.alcohol_treatment_program_name).to eq "Prog Ram"
    end
  end
end
