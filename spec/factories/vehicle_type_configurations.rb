FactoryBot.define do
  factory :vehicle_type_configuration do
    vehicle_type { [ 'Private Vehicle', 'Commercial Vehicle', 'Motorcycle' ].sample }
    usage_type { [ 'Private Own Use', 'Commercial Own Goods', 'Hire and Reward' ].sample }
    expected_fields { { color: 'string', doors: 'integer' }.to_json }
  end
end
