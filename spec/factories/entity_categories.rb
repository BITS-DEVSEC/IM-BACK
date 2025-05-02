FactoryBot.define do
  factory :entity_category do
    association :entity_type
    association :entity, factory: :vehicle
    association :category

    trait :for_vehicle do
      association :entity_type, :vehicle
      association :entity, factory: :vehicle
      association :category, factory: [ :category, :vehicle_type ]
    end

    trait :for_usage do
      association :category, factory: [ :category, :usage_type ]
    end
  end
end
