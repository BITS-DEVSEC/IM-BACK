FactoryBot.define do
  factory :quotation_request do
    association :user
    association :insurance_product
    association :coverage_type
    association :insured_entity
    status { 'pending' }
    form_data { { example_key: "example_value" } }
  end
end
