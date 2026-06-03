namespace :outgoing_emails do
  desc "Backfill outgoing email types"
  task backfill_email_type: :environment do
    OutgoingEmail.includes(:screener).find_each do |outgoing_email|
      email_type =
        if outgoing_email.screener.signed_at.nil? || outgoing_email.created_at.to_date == outgoing_email.screener.signed_at.to_date
          :screener_results
        else
          :post_results_survey
        end

      outgoing_email.update_columns(email_type: OutgoingEmail.email_types[email_type])
    end
  end
end
