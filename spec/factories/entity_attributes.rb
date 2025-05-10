FactoryBot.define do
  factory :entity_attribute do
    association :entity_type
    association :entity, factory: :vehicle

    # default attribute_definition should be text if you're setting string values
    association :attribute_definition, factory: :attribute_definition, data_type: 'string'
    value { Faker::Lorem.word }

    trait :numeric do
      association :attribute_definition, factory: :attribute_definition, data_type: 'integer'
      value { rand(1..1000).to_s }
    end

    trait :decimal do
      association :attribute_definition, factory: :attribute_definition, data_type: 'decimal'
      value { rand(0.0..1000.0).round(2).to_s }
    end

    trait :boolean do
      association :attribute_definition, factory: :attribute_definition, data_type: 'boolean'
      value { [ true, false ].sample.to_s }
    end

    trait :for_vehicle do
      association :entity_type, :vehicle
      association :entity, factory: :vehicle
    end
  end
end
