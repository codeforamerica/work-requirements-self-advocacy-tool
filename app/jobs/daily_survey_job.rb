class DailySurveyJob < ApplicationJob
  queue_as :default

  def perform
    time_zone = "America/Los_Angeles"

    signed_at_range =
      Time.use_zone(time_zone) do
        Rails.env.production? ? 14.days.ago.all_day : Date.yesterday.all_day
      end

    screeners = Screener.where(signed_at: signed_at_range).where.not(email: [nil, ""])

    Rails.logger.info "Found #{screeners.count} screeners with email addresses signed #{signed_at_range.begin.to_date}"

    screeners.find_each do |screener|
      Rails.logger.info "Processing screener #{screener.id} for survey"
      outgoing_email = OutgoingEmail.create(screener: screener)
      begin
        SurveyMailer.send_survey(outgoing_email: outgoing_email).deliver_now
        outgoing_email.update(sent_at: DateTime.now)
        Rails.logger.info "Processed screener #{screener.id} for survey. Sent email #{outgoing_email.id}."
      rescue => e
        Rails.logger.error "Failed sending survey for screener #{screener.id}: #{e.class} - #{e.message}"
        next
      end
    end
  end
end
