class WorkRulesApplyUnmetController < QuestionController
  def show_progress_bar
    false
  end

  helper_method :time_limit_text

  def self.show?(screener)
    !screener.exempt_from_work_rules? && !screener.complies_with_work_rules? && super
  end

  def time_limit_text
    if @current_screener.state == "NC"
      I18n.t("views.work_rules_apply_unmet.edit.time_limit_text_nc")
    else
      I18n.t("views.work_rules_apply_unmet.edit.time_limit_text_default")
    end
  end
end
