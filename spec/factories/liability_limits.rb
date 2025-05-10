FactoryBot.define do
  factory :liability_limit do
    association :insurance_type
    association :coverage_type
    sequence(:benefit_type) { |n| "Benefit Type #{n}" }
    min_limit { rand(10000..50000.0).round(2) }
    max_limit { rand(100000..500000.0).round(2) }

    trait :bodily_injury do
      benefit_type { "Bodily Injury" }
      min_limit { 0 }
      max_limit { 250000 }
    end

    trait :property_damage do
      benefit_type { "Property Damage" }
      min_limit { 0 }
      max_limit { 200000 }
    end

    trait :death do
      benefit_type { "Death" }
      min_limit { 30000 }
      max_limit { 250000 }
    end

    trait :medical do
      benefit_type { "Emergency Medical Treatment" }
      min_limit { 0 }
      max_limit { 15000 }
    end

    trait :for_motor_insurance do
      after(:build) do |liability_limit|
        insurance_type = InsuranceType.find_by(name: 'Motor') ||
                         create(:insurance_type, name: 'Motor')
        coverage_type = CoverageType.find_by(name: 'Third Party', insurance_type: insurance_type) ||
                        create(:coverage_type, name: 'Third Party', insurance_type: insurance_type)

        liability_limit.insurance_type = insurance_type
        liability_limit.coverage_type = coverage_type
      end
    end

    trait :for_health_insurance do
      after(:build) do |liability_limit|
        insurance_type = InsuranceType.find_by(name: 'Health') ||
                         create(:insurance_type, name: 'Health')
        coverage_type = CoverageType.find_by(name: 'Basic', insurance_type: insurance_type) ||
                        create(:coverage_type, name: 'Basic', insurance_type: insurance_type)

        liability_limit.insurance_type = insurance_type
        liability_limit.coverage_type = coverage_type
      end
    end

    trait :zero_min_limit do
      min_limit { 0 }
    end

    trait :high_max_limit do
      max_limit { 1000000 }
    end
  end
end
