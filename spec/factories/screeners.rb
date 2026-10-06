FactoryBot.define do
  factory :screener do
    state { "NC" }
    county { "Durham County" }
    age_range { "18_to_49" }
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
    age_range { "65_or_older" }
  end

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
