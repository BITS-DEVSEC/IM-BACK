FactoryBot.define do
  factory :policy do
    association :user
    association :insured_entity
    association :coverage_type
    sequence(:policy_number) { |n| "POL-#{Time.current.to_i}-#{n}" }
    start_date { Date.current }
    end_date { 1.year.from_now.to_date }
    premium_amount { rand(1000..5000.0).round(2) }
    status { [ "active", "pending", "cancelled", "expired" ].sample }

    trait :active do
      status { "active" }
    end

    trait :with_vehicle do
      after(:build) do |policy|
        policy.insured_entity ||= create(:insured_entity, :with_vehicle)
      end
    end
  end
end
