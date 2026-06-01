class DownloadFormController < ExemptionAwareQuestionController
  before_action :email_pdf, only: :edit
  def show_progress_bar
    false
  end

  def email_pdf
    return if current_screener.email.blank?
    outgoing_email = OutgoingEmail.create(screener: current_screener)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)
  end
end
