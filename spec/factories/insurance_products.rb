FactoryBot.define do
  factory :insurance_product do
    association :insurer
    association :coverage_type
    name { Faker::Commerce.unique.product_name }
    description { Faker::Lorem.paragraph }
    estimated_price { Faker::Commerce.price(range: 100..10_000.0) }
    customer_rating { Faker::Number.between(from: 1, to: 5).to_f }
    status { %w[active inactive].sample }

    trait :active do
      status { 'active' }
    end

    trait :inactive do
      status { 'inactive' }
    end
  end
end
