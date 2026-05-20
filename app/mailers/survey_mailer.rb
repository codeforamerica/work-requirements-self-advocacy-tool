class SurveyMailer < ApplicationMailer
  default from: "noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")

  SURVEY_LINKS = {
    LocationData::States::NORTH_CAROLINA => "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3kgHxveKeorfFC6",
    LocationData::States::DELAWARE => "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_8rdcUjhPOWA0XzM"
  }.freeze

  def send_survey(outgoing_email:)
    Rails.logger.info "Sending survey to #{outgoing_email.screener.id}"
    @screener = outgoing_email.screener
    @survey_link = SURVEY_LINKS.fetch(@screener.state)

    attachments.inline["gbh_email_header.png"] = File.binread(Rails.root.join("app/assets/images/gbh_email_header.png"))

    if ENV["SES_CONFIGURATION_SET"]
      headers["X-SES-CONFIGURATION-SET"] = ENV["SES_CONFIGURATION_SET"]
    end

    if ENV["SES_CONTACT_LIST"]
      headers["X-SES-LIST-MANAGEMENT-OPTIONS"] = "#{ENV["SES_CONTACT_LIST"]}; topic=general"
    end

    mail(to: @screener.email, subject: I18n.t("views.survey_mailer.send_survey.subject"))
  end
end
