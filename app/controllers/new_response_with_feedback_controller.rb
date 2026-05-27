class NewResponseWithFeedbackController < QuestionController
  def show_progress_bar
    false
  end

  def self.attributes_edited
    [
      :survey_very_easy_experience,
     :survey_easy_experience,
     :survey_neutral_experience,
     :survey_somewhat_difficult_experience,
     :survey_very_difficult_experience
    ]
  end
end
