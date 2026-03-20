class BasicInfoSsnController < QuestionController
  include BasicInfoConcern

  def self.show?(screener)
    screener.case_number.blank?
  end

  def self.attributes_edited
    [:ssn]
  end
end
