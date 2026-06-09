require "rails_helper"

RSpec.describe NewResponseWithFeedbackController, type: :controller do
  describe "#update" do
    it "persists the value to the current screener" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {survey_ease_of_experience: "easy"}}
      screener.reload
      expect(screener.survey_ease_of_experience).to eq "easy"
    end
  end
end
