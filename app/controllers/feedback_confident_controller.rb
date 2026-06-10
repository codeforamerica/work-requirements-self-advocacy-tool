class FeedbackConfidentController < QuestionController
  def show_progress_bar
    false
  end

  def show_progress_percentage
    false
  end

  def self.attributes_edited
    [:survey_confidence_in_exemption_rules]
  end
end
