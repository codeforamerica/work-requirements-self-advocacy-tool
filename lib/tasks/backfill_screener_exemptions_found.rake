require "active_support/testing/time_helpers"

namespace :backfill do
  desc "Backfill exemptions_found for screeners that already have an outcome"
  task screener_exemptions_found: :environment do
    # create a throwaway object to keep any changes from affecting the rest of the app
    clock = Object.new.extend(ActiveSupport::Testing::TimeHelpers)

    scope = Screener.where(exemptions_found: nil).where.not(outcome: nil)

    total = scope.count
    puts "Backfilling #{total} screeners with exemptions_found..."

    updated = 0
    errored = 0

    scope.find_each do |screener|
      recorded_at = screener.outcome_arrived_at || screener.updated_at

      # travels to the time the outcome was recorded so age-related exemptions are what they were
      # when the outcome was recorded, not what they are now
      reasons = clock.travel_to(recorded_at) { screener.exemption_reasons }

      # update_column bypasses callbacks and validations — appropriate for backfills
      screener.update_column(:exemptions_found, reasons)
      updated += 1
    rescue => e
      Rails.logger.error "Failed to backfill screener #{screener.id}: #{e.message}"
      errored += 1
    end

    puts "Done. Updated: #{updated}, Errored: #{errored}"
  end
end
