class DownloadFormController < QuestionController
  def show_progress_bar
    false
  end

  def email_pdf
    outgoing_email = OutgoingEmail.create(screener: current_screener)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)
    flash[:notice] = I18n.t("views.download_form.edit.notice")
    redirect_to download_form_path
  end
end
