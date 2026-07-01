class BasicInfoEmailNudgeController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.navigation_actions
    [:display]
  end

  def self.show?(screener)
    screener.email.blank? && super
  end
end
