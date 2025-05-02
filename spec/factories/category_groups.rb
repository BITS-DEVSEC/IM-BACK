FactoryBot.define do
  factory :category_group do
    association :insurance_type
    sequence(:name) { |n| "Category Group #{n}" }

    trait :vehicle_type do
      name { "Vehicle Type" }
    end

    trait :usage_type do
      name { "Usage Type" }
    end

    trait :with_categories do
      transient do
        categories_count { 3 }
      end

      after(:create) do |category_group, evaluator|
        create_list(:category, evaluator.categories_count, category_group: category_group)
      end
    end
  end
end
