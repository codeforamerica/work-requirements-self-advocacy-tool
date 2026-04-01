class WorkRulesApplyUnmetController < QuestionController
  def show_progress_bar
    false
  end

  def show?(screener)
    super
  end
end
