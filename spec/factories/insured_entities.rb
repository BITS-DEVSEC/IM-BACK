FactoryBot.define do
  factory :insured_entity do
    user { nil }
    insurance_type { nil }
    entity_type { nil }
    entity_id { "" }
  end
end
