class ProofGuidanceController < ExemptionAwareQuestionController
  def show_progress_bar
    false
  end

  helper_method :display_american_indian_guidance?

  def display_american_indian_guidance?
    @current_screener.state != "NC" && @current_screener.is_american_indian_yes?
  end
end
