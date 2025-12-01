class LanguagePreferenceController < QuestionController
  def self.attributes_edited
    [:language_preference_written, :language_preference_spoken]
  end

  helper_method :dropdown_options
  def dropdown_options
    [ OpenStruct.new(value: "english", label: "English"),
      OpenStruct.new(value: "spanish", label: "Spanish"),
      OpenStruct.new(value: "unfilled", label: "Gibberish") ]
  end
end
