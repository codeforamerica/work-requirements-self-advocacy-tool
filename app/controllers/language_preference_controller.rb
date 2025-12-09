class LanguagePreferenceController < QuestionController
  helper_method :dropdown_options

  def self.attributes_edited
    [:language_preference_written, :language_preference_spoken]
  end

  def dropdown_options
    [OpenStruct.new(value: "english", label: "English"),
      OpenStruct.new(value: "spanish", label: "Spanish")]
  end
end
