class BasicInfoCaseNumberController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:case_number]
  end
end
