namespace :outgoing_emails do
  desc "Backfill outgoing email email field from screener email"
  task backfill_email: :environment do
    OutgoingEmail.includes(:screener).find_each do |outgoing_email|
      outgoing_email.update_columns(email: outgoing_email.screener&.email)
    end
  end
end
