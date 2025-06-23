FactoryBot.define do
  factory :customer do
    association :user
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
    gender { [ 'Male', 'Female' ].sample }
    region { Faker::Address.state }
    subcity { Faker::Address.city }
    woreda { Faker::Address.community }

    trait :with_current_address do
      after(:create) do |customer|
        create(:residence_address, :current, customer: customer)
      end
    end

    trait :with_multiple_addresses do
      after(:create) do |customer|
        create_list(:residence_address, 2, customer: customer, is_current: false)
        create(:residence_address, :current, customer: customer)
      end
    end
  end
end
