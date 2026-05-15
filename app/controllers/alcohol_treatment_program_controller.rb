class AlcoholTreatmentProgramController < QuestionController
  include WrExemptionsConcern

  helper_method :state_notice_text
  def self.attributes_edited
    [:is_in_alcohol_treatment_program, :alcohol_treatment_program_name]
  end

  def state_notice_text
    if @current_screener.state == LocationData::States::NORTH_CAROLINA
      I18n.t("views.alcohol_treatment_program.edit.notice_text_nc")
    else
      I18n.t("views.alcohol_treatment_program.edit.notice_text_de")
    end
  end
end
