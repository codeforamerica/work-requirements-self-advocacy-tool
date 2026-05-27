require "rails_helper"

RSpec.describe NewResponseWithFeedbackController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        survey_very_easy_experience: "no",
        survey_easy_experience: "yes",
        survey_neutral_experience: "no",
        survey_somewhat_difficult_experience: "yes",
        survey_very_difficult_experience: "no"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.survey_very_easy_experience).to eq "no"
      expect(screener.survey_easy_experience).to eq "yes"
      expect(screener.survey_neutral_experience).to eq "no"
      expect(screener.survey_somewhat_difficult_experience).to eq "yes"
      expect(screener.survey_very_difficult_experience).to eq "no"
    end
  end
end
