FactoryBot.define do
  factory :screener do
    state { "NC" }
    county { "Durham County" }
    birth_date { 30.years.ago.to_date }
  end

  trait :with_nc_screener do
    state { "NC" }
    county { "Durham County" }
    nc_screener { create(:nc_screener) }
  end

  trait :with_exemption do
    is_american_indian { "yes" }
    preventing_work_medical_condition { "yes" }
  end

  trait :age_exempt do
    birth_date { 70.years.ago.to_date }
  end

  # Meets the 20-hour work rule without qualifying for the earnings exemption
  # (under 30 hours and under the weekly earnings minimum).
  trait :meets_work_rules do
    is_working { "yes" }
    working_hours { 20 }
    working_weekly_earnings { 100.00 }
  end

  trait :with_earnings_exemption do
    is_working { "yes" }
    working_hours { 35 }
  end
end
