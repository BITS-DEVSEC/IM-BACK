FactoryBot.define do
  factory :insurer do
    association :user
    name { Faker::Company.unique.name }
    description { Faker::Company.catch_phrase }
    contact_email { Faker::Internet.email }
    contact_phone { Faker::PhoneNumber.phone_number }

    trait :with_products do
      after(:create) do |insurer|
        create_list(:insurance_product, 3, insurer: insurer)
      end
    end
  end
end
