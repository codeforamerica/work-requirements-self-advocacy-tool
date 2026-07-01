class NewResponseController < QuestionController
  def self.navigation_actions
    [:display]
  end

  def show_progress_bar
    false
  end

  def show_progress_percentage
    false
  end
end
