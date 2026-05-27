class FeedbackResultController < QuestionController
  CHARACTER_LIMIT = 400

  def show_progress_bar
    false
  end

  def self.attributes_edited
    [
      :survey_plan_to_submit_results_to_site,
      :survey_plan_to_email_results,
      :survey_plan_to_bring_results_to_interview,
      :survey_plan_to_bring_results_to_organization,
      :survey_plan_to_keep_it_in_records,
      :survey_additional_feedback
    ]
  end
end
