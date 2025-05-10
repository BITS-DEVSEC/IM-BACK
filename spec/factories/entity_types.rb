FactoryBot.define do
  factory :entity_type do
    sequence(:name) { |n| "Entity Type #{n}" }

    trait :vehicle do
      name { 'Vehicle' }
    end
  end
end
