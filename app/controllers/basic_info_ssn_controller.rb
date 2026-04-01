class BasicInfoSsnController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.show?(screener)
    screener.case_number.blank? && super
  end

  def self.attributes_edited
    [:ssn_last_four]
  end
end
