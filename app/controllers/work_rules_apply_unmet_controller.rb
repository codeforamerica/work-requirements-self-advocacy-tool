class WorkRulesApplyUnmetController < QuestionController
  def show_progress_bar
    false
  end

  # Only show when no exemptions are identified
  def self.show?(screener)
    !(screener&.exempt_from_work_rules? && super)
  end
end
