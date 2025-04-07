FactoryBot.define do
  factory :attribute_metadatum do
    attribute_definition { nil }
    label { "MyString" }
    is_dropdown { false }
    dropdown_options { "" }
    min_value { "9.99" }
    max_value { "9.99" }
    validation_regex { "MyString" }
    help_text { "MyText" }
  end
end
