class LanguagePreferenceController < QuestionController
  helper_method :dropdown_options

  def self.attributes_edited
    [:language_preference_written, :language_preference_spoken]
  end

  def dropdown_options
    [OpenStruct.new(value: "english", label: "english"),
      OpenStruct.new(value: "spanish", label: "spanish")]
  end

  private

  def after_update_success
    I18n.locale = locale
  end
end
