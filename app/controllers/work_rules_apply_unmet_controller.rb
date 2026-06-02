class WorkRulesApplyUnmetController < QuestionController
  before_action :save_outcome, only: :edit

  def show_progress_bar
    false
  end

  helper_method :time_limit_text

  def self.show?(screener)
    !screener.exempt_from_work_rules? && !screener.complies_with_work_rules? && super
  end

  def time_limit_text
    if @current_screener.state == LocationData::States::NORTH_CAROLINA
      I18n.t("views.work_rules_apply_unmet.edit.time_limit_text_nc")
    else
      I18n.t("views.work_rules_apply_unmet.edit.time_limit_text_default")
    end
  end

  private

  def save_outcome
    current_screener.update!(outcome: Screener::NOT_EXEMPT_WORK_RULES_NOT_MET, outcome_arrived_at: Time.current)
  end
end
