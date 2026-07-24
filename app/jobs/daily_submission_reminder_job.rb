class DailySubmissionReminderJob < ApplicationJob
  queue_as :default

  def perform
    signed_at_range = Time.now.all_day

    screeners = Screener.where(signed_at: signed_at_range).where.not(email: [nil, ""])
      .where.not(id: OutgoingEmail.where(email_type: :submission_reminder).select(:screener_id))

    Rails.logger.info "Found #{screeners.count} screeners with email addresses signed #{signed_at_range.begin.to_date}"

    screeners.find_each do |screener|
      Rails.logger.info "Processing screener #{screener.id} for submission reminder"
      outgoing_email = OutgoingEmail.create!(screener: screener, email: screener.email, email_type: :submission_reminder)
      begin
        SubmissionReminderMailer.send_reminder(outgoing_email: outgoing_email).deliver_now
        outgoing_email.update(sent_at: DateTime.now)
        Rails.logger.info "Processed screener #{screener.id} for submission reminder. Sent email #{outgoing_email.id}."
      rescue Aws::SESV2::Errors::AccessDeniedException
        Rails.logger.warn("SES access denied for screener #{screener.id}")
        next
      rescue => e
        Rails.logger.error "Failed sending submission reminder for screener #{screener.id}: #{e.class}"
        next
      end
    end
  end
end
