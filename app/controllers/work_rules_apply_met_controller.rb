class WorkRulesApplyMetController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    screener.no_exemptions_and_greater_than_or_equal_to_20_hours_of_volunteer_work_or_training?
  end
end
