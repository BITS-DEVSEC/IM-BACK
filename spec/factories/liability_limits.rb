FactoryBot.define do
  factory :liability_limit do
    insurance_type { nil }
    coverage_type { nil }
    benefit_type { "MyString" }
    min_limit { "9.99" }
    max_limit { "9.99" }
  end
end
