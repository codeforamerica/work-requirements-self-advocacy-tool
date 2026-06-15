class SendOutgoingEmailJob < ApplicationJob
  queue_as :default

  discard_on Aws::SESV2::Errors::AccessDeniedException do |job, error|
    Rails.logger.warn("SES access denied, discarding email job | email_id=#{job.arguments.first} | error=#{error.message}")
  end

  def perform(email_id)
    outgoing_email = OutgoingEmail.find(email_id)
    ScreenerMailer.send_screener_results(outgoing_email: outgoing_email).deliver_now
    outgoing_email.update(sent_at: DateTime.now)
  end
end
