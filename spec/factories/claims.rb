FactoryBot.define do
  factory :claim do
    association :policy
    sequence(:claim_number) { |n| "CLM-#{Time.current.to_i}-#{n}" }
    description { Faker::Lorem.paragraph }
    claimed_amount { rand(1000..50_000.0).round(2) }
    status { 'draft' }

    after(:build) do |claim|
      if claim.policy && claim.policy.start_date
        start_date = claim.policy.start_date
        end_date = [ claim.policy.end_date, Date.current ].min
        claim.incident_date ||= Faker::Date.between(from: start_date, to: end_date)
      else
        claim.incident_date ||= Date.current - rand(1..30).days
      end
    end

    incident_location { "#{Faker::Address.street_address}, #{Faker::Address.city}" }
    incident_time { Faker::Time.between(from: 1.year.ago, to: Time.current) }
    incident_type { Claim::INCIDENT_TYPES.sample }
    damage_description { Faker::Lorem.sentence(word_count: 10) }
    vehicle_speed { "#{rand(20..80)} km/h" }
    distance_from_roadside { "#{rand(1..50)} meters" }
    horn_sounded { [ true, false ].sample }
    inside_vehicle { [ true, false ].sample }
    police_notified { [ true, false ].sample }
    third_party_involved { [ true, false ].sample }
    additional_details { Faker::Lorem.paragraph }

    transient do
      without_driver { false }
    end

    after(:create) do |claim, evaluator|
      create(:claim_driver, claim: claim) unless evaluator.without_driver
    end

    trait :draft do
      status { 'draft' }
    end

    trait :pending do
      status { 'pending' }
      submitted_at { rand(1..30).days.ago }
    end

    trait :approved do
      status { 'approved' }
      submitted_at { rand(10..30).days.ago }
    end

    trait :rejected do
      status { 'rejected' }
      submitted_at { rand(5..20).days.ago }
    end

    trait :paid do
      status { 'paid' }
      submitted_at { rand(20..60).days.ago }
      settlement_amount { claimed_amount * rand(0.7..1.0) }
    end

    trait :with_settlement do
      settlement_amount { claimed_amount * rand(0.8..1.0) }
    end

    trait :collision do
      incident_type { 'collision' }
      damage_description { 'Minor collision with another vehicle at an intersection. Front bumper damaged.' }
      horn_sounded { true }
      third_party_involved { true }
    end

    trait :theft do
      incident_type { 'theft' }
      damage_description { 'Vehicle was stolen from parking lot.' }
      police_notified { true }
    end

    trait :with_timeline do
      after(:create) do |claim|
        create_list(:claim_timeline, 3, claim: claim)
      end
    end
  end
end
