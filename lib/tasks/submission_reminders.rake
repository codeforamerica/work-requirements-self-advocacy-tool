namespace :submission_reminders do
  desc "One-time backfill: send the submission reminder email to screeners signed since June 1, 2026 who haven't received one yet"
  task backfill_missed: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    time_zone = "America/Los_Angeles"

    signed_at_range =
      Time.use_zone(time_zone) do
        Time.zone.local(2026, 6, 1).beginning_of_day..7.days.ago.end_of_day
      end

    screeners = Screener.where(signed_at: signed_at_range).where.not(email: [nil, ""])
                        .where.not(id: OutgoingEmail.where(email_type: :submission_reminder).where.not(sent_at: nil).select(:screener_id))

    Rails.logger.info "Found #{screeners.count} screeners with email addresses signed between #{signed_at_range.begin.to_date} and #{signed_at_range.end.to_date}"

    if dry_run
      Rails.logger.info "[DRY RUN] Would send to #{screeners.count} screener(s). Emails: #{screeners.pluck(:email).join(", ")}"
      next
    end

    screeners.find_each do |screener|
      Rails.logger.info "Processing screener #{screener.id} for backfilled submission reminder"
      outgoing_email = OutgoingEmail.create!(screener: screener, email: screener.email, email_type: :submission_reminder)
      begin
        SubmissionReminderMailer.send_reminder(outgoing_email: outgoing_email, use_recent_wording: true).deliver_now
        outgoing_email.update(sent_at: DateTime.now)
        Rails.logger.info "Processed screener #{screener.id} for backfilled submission reminder. Sent email #{outgoing_email.id}."
      rescue Aws::SESV2::Errors::AccessDeniedException
        Rails.logger.warn("SES access denied for screener #{screener.id}")
        next
      rescue => e
        Rails.logger.error "Failed sending backfilled submission reminder for screener #{screener.id}: #{e.class}"
        next
      end
    end

  end
end
