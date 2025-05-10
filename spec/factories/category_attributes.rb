FactoryBot.define do
  factory :category_attribute do
    association :category
    association :attribute_definition
    is_required { false }

    trait :required do
      is_required { true }
    end
  end
end
