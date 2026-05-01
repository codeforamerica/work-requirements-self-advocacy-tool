FactoryBot.define do
  factory :screener do
    state { "NC" }
    county { "Durham County" }
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

  trait :with_earnings_exemption do
    is_working { "yes" }
    working_hours { 35 }
  end
end
