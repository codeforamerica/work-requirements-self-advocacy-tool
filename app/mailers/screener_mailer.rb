class ScreenerMailer < ApplicationMailer
  def send_screener_results(outgoing_email:)
    @screener = outgoing_email.screener

    attach_header_image
    apply_ses_headers

    attachments["getbenefitshelp.pdf"] = {
      mime_type: "application/pdf",
      content: @screener.pdf
    }

    mail(to: @screener.email, subject: I18n.t("views.screener_mailer.send_screener_results.subject"))
  end
end
