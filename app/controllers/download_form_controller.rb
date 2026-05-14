class DownloadFormController < ExemptionAwareQuestionController
  before_action :email_pdf
  helper_method :state_epass_html
  def show_progress_bar
    false
  end

  def state_epass_html
    if @current_screener.state == LocationData::States::NORTH_CAROLINA
      I18n.t("views.download_form.edit.epass_nc_html")
    else
      I18n.t("views.download_form.edit.epass_de_html")
    end
  end

  def email_pdf
    return if current_screener.email.blank?
    outgoing_email = OutgoingEmail.create(screener: current_screener)
    SendOutgoingEmailJob.perform_later(outgoing_email.id)
  end
end
