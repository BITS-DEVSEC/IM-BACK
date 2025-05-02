FactoryBot.define do
  factory :claim do
    association :policy
    sequence(:claim_number) { |n| "CLM-#{Time.current.to_i}-#{n}" }
    description { Faker::Lorem.paragraph }
    claimed_amount { rand(1000..50_000.0).round(2) }
    incident_date { |claim| (claim.policy.start_date..Date.current).to_a.sample }
    status { [ 'pending', 'approved', 'rejected', 'paid' ].sample }

    trait :pending do
      status { 'pending' }
    end

    trait :approved do
      status { 'approved' }
    end

    trait :rejected do
      status { 'rejected' }
    end

    trait :paid do
      status { 'paid' }
    end
  end
end
