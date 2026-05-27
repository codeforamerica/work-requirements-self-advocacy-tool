require "rails_helper"

RSpec.describe FeedbackResultController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        survey_plan_to_submit_results_to_site: "yes",
        survey_plan_to_email_results: "no",
        survey_plan_to_bring_results_to_interview: "yes",
        survey_plan_to_bring_results_to_organization: "no",
        survey_plan_to_keep_it_in_records: "yes",
        survey_additional_feedback: "I love taking surveys!"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.survey_plan_to_submit_results_to_site).to eq "yes"
      expect(screener.survey_plan_to_email_results).to eq "no"
      expect(screener.survey_plan_to_bring_results_to_interview).to eq "yes"
      expect(screener.survey_plan_to_bring_results_to_organization).to eq "no"
      expect(screener.survey_plan_to_keep_it_in_records).to eq "yes"
      expect(screener.survey_additional_feedback).to eq "I love taking surveys!"
    end
  end
end
