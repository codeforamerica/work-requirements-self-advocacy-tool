class BasicInfoCaseNumberController < ExemptionAwareQuestionController
  include BasicInfoConcern

  CHARACTER_LIMIT = 24

  def self.attributes_edited
    [:case_number]
  end
end
