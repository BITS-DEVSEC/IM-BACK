FactoryBot.define do
  factory :quotation_request do
    association :user
    association :insurance_type
    association :coverage_type
    association :vehicle
    status { "draft" }
    form_data { { example_key: "example_value" } }
  end
end
