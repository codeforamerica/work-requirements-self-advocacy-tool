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
end
