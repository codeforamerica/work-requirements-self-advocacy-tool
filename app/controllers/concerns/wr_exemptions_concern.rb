module WrExemptionsConcern
  extend ActiveSupport::Concern

  def progress_bar_step
    1
  end

  def section_name
    I18n.t("general.work_rules")
  end
end
