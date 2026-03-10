class DownloadFormController < QuestionController
  def show_progress_bar
    false
  end

  # TODO: Remove this method.
  # There are additional tickets for when the email is being sent
  def email_pdf
    outgoing_email = OutgoingEmail.create(screener: current_screener)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)
    redirect_to download_form_path
  end
end
