class BasicInfoMilestoneController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.navigation_actions
    [:display]
  end
end
