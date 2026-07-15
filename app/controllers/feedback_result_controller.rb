class FeedbackResultController < QuestionController
  CHARACTER_LIMIT = 400

  def show_progress_bar
    false
  end

  def show_progress_percentage
    false
  end

  def self.attributes_edited
    [
      :survey_plan_to_submit_results_to_site,
      :survey_plan_to_email_results,
      :survey_plan_to_bring_results_to_interview,
      :survey_plan_to_bring_results_to_organization,
      :survey_plan_to_keep_it_in_records,
      :unsubmitted_because_already_reported,
      :unsubmitted_because_wont_be_accepted,
      :unsubmitted_because_process_too_hard,
      :unsubmitted_because_dont_qualify_for_exemptions,
      :unsubmitted_because_just_wanted_to_see_result,
      :unsubmitted_because_privacy_concerns,
      :unsubmitted_because_other,
      :unsubmitted_write_in,
      :survey_additional_feedback
    ]
  end
end
