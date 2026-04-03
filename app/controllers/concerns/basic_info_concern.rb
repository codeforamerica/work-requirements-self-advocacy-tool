module BasicInfoConcern
  extend ActiveSupport::Concern

  def progress_bar_step
    3
  end

  def section_name
    I18n.t("general.basic_information")
  end
end
