module PersonalSituationsConcern
  extend ActiveSupport::Concern

  def progress_bar_step
    2
  end

  def section_name
    I18n.t("general.personal_situations")
  end
end
