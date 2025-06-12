FactoryBot.define do
  factory :coverage_type do
    association :insurance_type
    sequence(:name) { |n| "Coverage Type #{n}" }
    description { Faker::Lorem.paragraph }

    trait :third_party do
      name { 'Third Party' }
      description { 'Third party liability coverage' }
    end

    trait :with_insurance_products do
      transient do
        products_count { 3 }
      end

      after(:create) do |coverage_type, evaluator|
        create_list(:insurance_product, evaluator.products_count, coverage_type: coverage_type)
      end
    end
  end
end
