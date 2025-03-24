FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    phone_number { Faker::PhoneNumber.cell_phone }
    fin { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    verified { false }

    trait :verified do
      verified { true }
    end
  end
end
