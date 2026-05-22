class SurveyMailer < ApplicationMailer
  def send_survey(outgoing_email:)
    Rails.logger.info "Sending survey to #{outgoing_email.screener.id}"
    @screener = outgoing_email.screener

    state_info = LocationData::States::STATES_INFO.fetch(@screener.state)
    @survey_link = state_info.fetch(:survey_url)

    attach_header_image
    apply_ses_headers

    mail(to: @screener.email, subject: I18n.t("views.survey_mailer.send_survey.subject"))
  end
end
