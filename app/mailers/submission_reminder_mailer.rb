class SubmissionReminderMailer < ApplicationMailer
  RESEARCH_FORM_URL = "https://docs.google.com/forms/d/1nBCIU6Uh5sMZgBUw6R0Eyx8mKBH6u5MhSpyZYYmETC0/viewform".freeze

  def send_reminder(outgoing_email:)
    Rails.logger.info "Sending submission reminder to #{outgoing_email.screener.id}"
    @screener = outgoing_email.screener
    @research_link = RESEARCH_FORM_URL

    locale = @screener.locale.presence || I18n.default_locale
    I18n.with_locale(locale) do
      @online_portal = I18n.t("views.submission_reminder_mailer.send_reminder.online_portal_#{@screener.state.to_s.downcase}")

      attach_header_image
      apply_ses_headers

      mail(to: @screener.email, subject: I18n.t("views.submission_reminder_mailer.send_reminder.subject"))
    end
  end
end
