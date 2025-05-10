FactoryBot.define do
  factory :attribute_definition do
    association :insurance_type
    sequence(:name) { |n| "attribute_#{n}" }
    data_type { %w[string integer decimal boolean date].sample }

    trait :string do
      data_type { "string" }
    end

    trait :integer do
      data_type { "integer" }
    end

    trait :decimal do
      data_type { "decimal" }
    end

    trait :with_metadata do
      after(:create) do |attribute_definition|
        create(:attribute_metadata, attribute_definition: attribute_definition)
      end
    end
  end
end
