class EmailController < QuestionController
  def self.attributes_edited
    [:email, :email_confirmation]
  end

  def progress_bar_step
    3
  end

  def section_name
    I18n.t("general.basic_information")
  end
end
