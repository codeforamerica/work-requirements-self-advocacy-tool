class NewResponseWithFeedbackController < QuestionController
  def show_progress_bar
    false
  end

  def self.attributes_edited
    [:survey_ease_of_experience]
  end
end
