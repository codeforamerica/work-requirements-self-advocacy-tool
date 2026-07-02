class BasicInfoEmailNudgeController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.show?(screener)
    screener.email.blank? && super
  end
end
