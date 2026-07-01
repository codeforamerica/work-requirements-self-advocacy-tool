class DownloadFormController < ExemptionAwareQuestionController
  before_action :email_pdf, :save_outcome, only: :display

  def self.navigation_actions
    [:display]
  end

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
end
