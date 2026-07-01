namespace :screeners do
  desc "Backfill session tokens for screeners that don't have one"
  task backfill_session_tokens: :environment do
    Screener.where(session_token: nil).find_each do |screener|
      screener.update_column(:session_token, SecureRandom.hex(20))
    end
  end
end
