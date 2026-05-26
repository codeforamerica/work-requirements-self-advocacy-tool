class BasicInfoCaseNumberController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:case_number]
  end

  helper_method :case_number_label, :office_name

  def case_number_label
    if @current_screener.state == LocationData::States::NORTH_CAROLINA
      I18n.t("views.basic_info_case_number.edit.help_text_county_letter.case_number_label_nc")
    else
      I18n.t("views.basic_info_case_number.edit.help_text_county_letter.case_number_label_default")
    end
  end

  def office_name
    if @current_screener.state == LocationData::States::NORTH_CAROLINA
      I18n.t("views.basic_info_case_number.edit.help_text_county_letter.office_name_nc", county: @current_screener.county)
    else
      I18n.t("views.basic_info_case_number.edit.help_text_county_letter.office_name_default")
    end
  end
end
