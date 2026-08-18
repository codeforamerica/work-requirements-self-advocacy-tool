class DownloadFormController < ExemptionAwareQuestionController
  before_action :redirect_unless_state_present, only: :display
  before_action :email_pdf, :save_outcome, only: :display

  def show_progress_bar
    false
  end

  def email_pdf
    if (reason = current_screener.screener_results_email_block_reason)
      Rails.logger.info("Skipping screener results email for Screener #{current_screener.id}: #{reason}")
      return
    end

    outgoing_email = OutgoingEmail.create!(screener: current_screener, email: current_screener.email, email_type: :screener_results)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)

    Rails.logger.info("Created screener results email #{outgoing_email.id} for Screener #{current_screener.id}")
  end

  private

  def outcome_value
    Screener::EXEMPT
  end

  # A blank/unrecognized state here means the screener bypassed the normal flow
  # (LocationController runs first and always sets it), not a legitimate value.
  def redirect_unless_state_present
    redirect_to root_path unless LocationData::States::STATES_INFO.key?(current_screener.state)
  end
end
