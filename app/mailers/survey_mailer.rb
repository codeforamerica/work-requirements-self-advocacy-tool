class SurveyMailer < ApplicationMailer
  default from: "noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")

  def send_survey(outgoing_email:)
    Rails.logger.info "Sending survey to #{outgoing_email.screener.id}"
    @screener = outgoing_email.screener
    attachments.inline["gbh_email_header.png"] = File.binread(Rails.root.join("app/assets/images/gbh_email_header.png"))

    if ENV["SES_CONFIGURATION_SET"]
      headers["X-SES-CONFIGURATION-SET"] = ENV["SES_CONFIGURATION_SET"]
    end

    if ENV["SES_CONTACT_LIST"]
      headers["X-SES-LIST-MANAGEMENT-OPTIONS"] = "#{ENV["SES_CONTACT_LIST"]}; topic=general"
    end

    mail(to: @screener.email, subject: I18n.t("views.screener_mailer.send_screener_results.subject"))
  end
end
