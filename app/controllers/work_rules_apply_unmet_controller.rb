class WorkRulesApplyUnmetController < QuestionController
  before_action :save_outcome, only: :display

  def show_progress_bar
    false
  end

  def self.show?(screener)
    !screener.exempt_from_work_rules? && !screener.complies_with_work_rules? && super
  end

  def outcome_value
    Screener::NOT_EXEMPT_WORK_RULES_NOT_MET
  end
end
