namespace :backfill do
  desc "Backfill outcome and outcome_arrived_at for screeners that completed the flow"
  task screener_outcomes: :environment do
    # Age-exempt screeners may never reach signed_at, so scope on birth_date instead
    scope = Screener.where(outcome: nil).where.not(birth_date: nil)

    total = scope.count
    puts "Backfilling #{total} screeners..."

    updated = 0
    errored = 0

    scope.find_each do |screener|
      reference_date = (screener.signed_at || screener.updated_at).to_date
      age_at_time = ((reference_date - screener.birth_date) / 365.25).to_i

      outcome = if age_at_time >= 65 || age_at_time < 18
        Screener::AGE_EXEMPT
      elsif screener.exempt_from_work_rules?
        Screener::EXEMPT
      elsif screener.complies_with_work_rules?
        Screener::NOT_EXEMPT_WORK_RULES_MET
      elsif !screener.exempt_from_work_rules? && !screener.complies_with_work_rules?
        Screener::NOT_EXEMPT_WORK_RULES_NOT_MET
      end

      next if outcome.nil?

      # update_columns bypasses callbacks and validations — appropriate for backfills
      screener.update_columns(
        outcome: outcome,
        outcome_arrived_at: screener.signed_at || screener.updated_at
      )
      updated += 1
    rescue => e
      Rails.logger.error "Failed to backfill screener #{screener.id}: #{e.message}"
      errored += 1
    end

    puts "Done. Updated: #{updated}, Errored: #{errored}"
  end
end
