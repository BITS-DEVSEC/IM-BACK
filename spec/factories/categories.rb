FactoryBot.define do
  factory :category do
    association :category_group
    sequence(:name) { |n| "Category #{n}" }

    trait :vehicle_type do
      after(:create) do |category|
        create(:category_group, name: 'Vehicle Type', category: category)
      end
    end

    trait :usage_type do
      after(:create) do |category|
        create(:category_group, name: 'Usage Type', category: category)
      end
    end

    trait :with_attributes do
      after(:create) do |category|
        create_list(:category_attribute, 2, category: category)
      end
    end
  end
end
