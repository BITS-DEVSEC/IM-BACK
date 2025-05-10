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
    woreda { Faker::Address.street_name }
  end
end
