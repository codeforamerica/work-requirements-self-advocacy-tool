class ScreenerMailer < ApplicationMailer
  default from: "noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")

  def send_screener_results(outgoing_email:)
    @screener = outgoing_email.screener
    attachments.inline["gbh_email_header.png"] = File.binread(Rails.root.join("app/assets/images/gbh_email_header.png"))
    attachments["work_requirements.pdf"] = {
      mime_type: "application/pdf",
      content: PdfFiller::PacketPdf.new(@screener).combined_pdf
    }
    mail(to: @screener.email, subject: I18n.t("views.screener_mailer.send_screener_results.subject"))
  end
end
