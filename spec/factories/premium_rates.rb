FactoryBot.define do
  factory :premium_rate do
    insurance_type { nil }
    criteria { "" }
    rate_type { "MyString" }
    rate { "9.99" }
    effective_date { "2025-04-07" }
    status { "MyString" }
  end
end
