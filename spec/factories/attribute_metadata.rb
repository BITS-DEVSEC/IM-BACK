FactoryBot.define do
  factory :attribute_metadata do
    association :attribute_definition
    sequence(:label) { |n| "Attribute Label #{n}" }
    is_dropdown { false }
    dropdown_options { "" }
    min_value { "0" }
    max_value { "100" }
    validation_regex { nil }
    help_text { "Help text for this attribute" }

    trait :dropdown do
      is_dropdown { true }
      dropdown_options { [ "Option 1", "Option 2", "Option 3" ].to_json }
      min_value { nil }
      max_value { nil }
    end

    trait :numeric do
      is_dropdown { false }
      min_value { "0" }
      max_value { "1000" }
      validation_regex { "^[0-9]+$" }
    end

    trait :text do
      is_dropdown { false }
      min_value { nil }
      max_value { nil }
      validation_regex { "^[a-zA-Z0-9\s]+$" }
    end
  end
end
