class WorkRulesApplyUnmetController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    !screener&.exempt_from_work_rules?
  end
end
