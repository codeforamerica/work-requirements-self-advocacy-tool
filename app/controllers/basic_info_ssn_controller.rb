class BasicInfoSsnController < QuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:ssn]
  end
end
