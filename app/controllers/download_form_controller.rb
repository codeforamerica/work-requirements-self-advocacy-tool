class DownloadFormController < QuestionController
  def show_progress_bar
    false
  end

  before_action :email_pdf

  def show?(screener)
    !!(screener&.exempt_from_work_rules? && super)
  end

  def email_pdf
    return if current_screener.email.blank?

    outgoing_email = OutgoingEmail.create(screener: current_screener)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)
  end
end
