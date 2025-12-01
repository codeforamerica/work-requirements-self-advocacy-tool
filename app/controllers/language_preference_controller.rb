class LanguagePreferenceController < QuestionController
  def self.attributes_edited
    [:language_preference_written, :language_preference_spoken]
  end
end
