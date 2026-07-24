class SubmissionReminderMailerPreview < ActionMailer::Preview
  def send_reminder_nc_en
    reminder(state: "NC", locale: "en", nc_screener: FactoryBot.build(:nc_screener))
  end

  def send_reminder_nc_es
    reminder(state: "NC", locale: "es", nc_screener: FactoryBot.build(:nc_screener))
  end

  def send_reminder_de_en
    reminder(state: "DE", locale: "en", zip_code: "19735")
  end

  def send_reminder_de_es
    reminder(state: "DE", locale: "es", zip_code: "19735")
  end

  private

  def reminder(**attributes)
    screener = FactoryBot.build(
      :screener,
      email: "preview@example.com",
      first_name: "Dog",
      last_name: "Ham",
      **attributes
    )
    outgoing_email = FactoryBot.build(:outgoing_email, screener: screener)
    SubmissionReminderMailer.send_reminder(outgoing_email: outgoing_email)
  end
end
