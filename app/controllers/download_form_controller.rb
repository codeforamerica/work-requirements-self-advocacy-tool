class DownloadFormController < ExemptionAwareQuestionController
  before_action :email_pdf, only: :edit
  def show_progress_bar
    false
  end

  def email_pdf
    if (reason = current_screener.screener_results_email_block_reason)
      Rails.logger.info("Skipping screener results email for Screener #{current_screener.id}: #{reason}")
      return
    end

    outgoing_email = OutgoingEmail.create!(screener: current_screener, email: current_screener.email)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)
  end
end
