FactoryBot.define do
  factory :quotation_request do
    user
    association :coverage_type
    association :insurance_product
    form_data { { "additional_info" => Faker::Lorem.sentence } }
    status { "pending" }

    after(:build) do |quotation_request|
      entity_type = EntityType.find_or_create_by(name: 'Vehicle')

      vehicle = build(:vehicle)

      create(:customer, user: quotation_request.user) unless quotation_request.user.customer

      insured_entity = build(:insured_entity,
        user: quotation_request.user,
        entity: vehicle,
        entity_type: entity_type,
        insurance_type: quotation_request.coverage_type.insurance_type
      )

      quotation_request.insured_entity = insured_entity
    end

    trait :approved do
      status { "approved" }
    end

    trait :rejected do
      status { "rejected" }
    end
  end
end
