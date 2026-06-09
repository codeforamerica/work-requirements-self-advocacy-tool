class FeedbackConfidentController < QuestionController
  def show_progress_bar
    false
  end

  def self.attributes_edited
    [:survey_confidence_in_exemption_rules]
  end
end
