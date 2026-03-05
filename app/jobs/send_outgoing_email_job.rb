class SendOutgoingEmailJob < ApplicationJob
  queue_as :default

  def perform(email_id)
    outgoing_email = OutgoingEmail.find(email_id)
    ScreenerMailer.download_pdf(outgoing_email: outgoing_email).deliver_now
    outgoing_email.update(sent_at: DateTime.now)
  end
end
