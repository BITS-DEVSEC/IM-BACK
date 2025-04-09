FactoryBot.define do
  factory :claim do
    policy { nil }
    claim_number { "MyString" }
    description { "MyText" }
    claimed_amount { "9.99" }
    incident_date { "2025-04-08" }
    status { "MyString" }
  end
end
