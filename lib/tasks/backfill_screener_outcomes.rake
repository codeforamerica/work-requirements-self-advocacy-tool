namespace :backfill do
  desc "Backfill outcome and outcome_arrived_at for screeners that completed the flow"
  task screener_outcomes: :environment do
    scope = Screener.where(outcome: nil).where.not(signed_at: nil)

    total = scope.count
    puts "Backfilling #{total} screeners..."

    updated = 0
    errored = 0

    scope.find_each do |screener|
      outcome = if screener.exempt_from_work_rules?
        Screener::EXEMPT
      elsif screener.complies_with_work_rules?
        Screener::NOT_EXEMPT_WORK_RULES_MET
      else
        Screener::NOT_EXEMPT_WORK_RULES_NOT_MET
      end

      # update_columns bypasses callbacks and validations — appropriate for backfills
      screener.update_columns(
        outcome: outcome,
        outcome_arrived_at: screener.signed_at
      )
      updated += 1
    rescue => e
      Rails.logger.error "Failed to backfill screener #{screener.id}: #{e.message}"
      errored += 1
    end

    puts "Done. Updated: #{updated}, Errored: #{errored}"
  end
end
