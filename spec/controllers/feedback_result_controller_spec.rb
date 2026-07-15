require "rails_helper"

RSpec.describe FeedbackResultController, type: :controller do
  describe "#update" do
    it_behaves_like "rejects invalid enum values", fields: [
      :survey_plan_to_email_results,
      :survey_plan_to_submit_results_to_site,
      :survey_plan_to_bring_results_to_interview,
      :survey_plan_to_bring_results_to_organization,
      :survey_plan_to_keep_it_in_records,
      :unsubmitted_because_already_reported,
      :unsubmitted_because_wont_be_accepted,
      :unsubmitted_because_process_too_hard,
      :unsubmitted_because_dont_qualify_for_exemptions,
      :unsubmitted_because_just_wanted_to_see_result,
      :unsubmitted_because_privacy_concerns,
      :unsubmitted_because_other
    ]

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) do
        [{
          form_params: {
            survey_plan_to_submit_results_to_site: "yes",
            survey_plan_to_email_results: "no",
            survey_plan_to_bring_results_to_interview: "yes",
            survey_plan_to_bring_results_to_organization: "no",
            survey_plan_to_keep_it_in_records: "yes",
            unsubmitted_because_already_reported: "no",
            unsubmitted_because_wont_be_accepted: "yes",
            unsubmitted_because_process_too_hard: "no",
            unsubmitted_because_dont_qualify_for_exemptions: "no",
            unsubmitted_because_just_wanted_to_see_result: "no",
            unsubmitted_because_privacy_concerns: "yes",
            unsubmitted_because_other: "yes",
            unsubmitted_write_in: "My printer is broken",
            survey_additional_feedback: "I love taking surveys!"
          },
          expected_data: {
            survey_plan_to_submit_results_to_site: "yes",
            survey_plan_to_email_results: "no",
            survey_plan_to_bring_results_to_interview: "yes",
            survey_plan_to_bring_results_to_organization: "no",
            survey_plan_to_keep_it_in_records: "yes",
            unsubmitted_because_already_reported: "no",
            unsubmitted_because_wont_be_accepted: "yes",
            unsubmitted_because_process_too_hard: "no",
            unsubmitted_because_dont_qualify_for_exemptions: "no",
            unsubmitted_because_just_wanted_to_see_result: "no",
            unsubmitted_because_privacy_concerns: "yes",
            unsubmitted_because_other: "yes",
            has_unsubmitted_write_in: true,
            has_survey_additional_feedback: true
          }
        }]
      end
    end

    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        survey_plan_to_submit_results_to_site: "yes",
        survey_plan_to_email_results: "no",
        survey_plan_to_bring_results_to_interview: "yes",
        survey_plan_to_bring_results_to_organization: "no",
        survey_plan_to_keep_it_in_records: "yes",
        unsubmitted_because_already_reported: "no",
        unsubmitted_because_wont_be_accepted: "yes",
        unsubmitted_because_process_too_hard: "no",
        unsubmitted_because_dont_qualify_for_exemptions: "no",
        unsubmitted_because_just_wanted_to_see_result: "no",
        unsubmitted_because_privacy_concerns: "yes",
        unsubmitted_because_other: "yes",
        unsubmitted_write_in: "My printer is broken",
        survey_additional_feedback: "I love taking surveys!"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.survey_plan_to_submit_results_to_site).to eq "yes"
      expect(screener.survey_plan_to_email_results).to eq "no"
      expect(screener.survey_plan_to_bring_results_to_interview).to eq "yes"
      expect(screener.survey_plan_to_bring_results_to_organization).to eq "no"
      expect(screener.survey_plan_to_keep_it_in_records).to eq "yes"
      expect(screener.unsubmitted_because_already_reported).to eq "no"
      expect(screener.unsubmitted_because_wont_be_accepted).to eq "yes"
      expect(screener.unsubmitted_because_process_too_hard).to eq "no"
      expect(screener.unsubmitted_because_dont_qualify_for_exemptions).to eq "no"
      expect(screener.unsubmitted_because_just_wanted_to_see_result).to eq "no"
      expect(screener.unsubmitted_because_privacy_concerns).to eq "yes"
      expect(screener.unsubmitted_because_other).to eq "yes"
      expect(screener.unsubmitted_write_in).to eq "My printer is broken"
      expect(screener.survey_additional_feedback).to eq "I love taking surveys!"
    end
  end
end
