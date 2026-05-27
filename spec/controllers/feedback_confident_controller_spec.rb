require "rails_helper"

RSpec.describe FeedbackConfidentController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        survey_confidence_in_exemption_rules: "very",
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.survey_confidence_in_exemption_rules).to eq "very"
    end
  end
end
