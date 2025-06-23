FactoryBot.define do
  factory :residence_address do
    association :customer
    region { Faker::Address.state }
    subcity { Faker::Address.city }
    woreda { Faker::Number.number(digits: 2).to_s }
    zone { "#{subcity} Zone #{Faker::Number.between(from: 1, to: 5)}" }
    house_number { Faker::Address.building_number }
    is_current { false }

    trait :current do
      is_current { true }
    end

    trait :previous do
      is_current { false }
    end
  end
end
