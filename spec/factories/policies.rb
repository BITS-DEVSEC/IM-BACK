FactoryBot.define do
  factory :policy do
    user { nil }
    insured_entity { nil }
    coverage_type { nil }
    policy_number { "MyString" }
    start_date { "2025-04-07" }
    end_date { "2025-04-07" }
    premium_amount { "9.99" }
    status { "MyString" }
  end
end
