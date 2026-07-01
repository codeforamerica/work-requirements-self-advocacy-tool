class ProofGuidanceController < ExemptionAwareQuestionController
  def self.navigation_actions
    [:display]
  end

  def show_progress_bar
    false
  end
end
