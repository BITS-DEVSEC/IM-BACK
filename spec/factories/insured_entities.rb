FactoryBot.define do
  factory :insured_entity do
    association :user
    association :insurance_type
    association :entity_type, factory: [ :entity_type, :vehicle ]
    association :entity, factory: :vehicle

    after(:build) do |insured_entity|
      if insured_entity.entity.is_a?(Vehicle)
        insured_entity.entity_type = EntityType.find_by(name: 'Vehicle') ||
                                    create(:entity_type, :vehicle)
      end
    end

    trait :with_vehicle do
      after(:build) do |insured_entity|
        insured_entity.entity = create(:vehicle)
        insured_entity.entity_type = EntityType.find_by(name: 'Vehicle') ||
                                    create(:entity_type, :vehicle)
      end
    end

    trait :with_property do
      association :entity, factory: :property
      after(:build) do |insured_entity|
        insured_entity.entity_type = EntityType.find_by(name: 'Property') ||
                                    create(:entity_type, name: 'Property')
      end
    end

    trait :with_active_policy do
      after(:create) do |insured_entity|
        create(:policy, :active, insured_entity: insured_entity)
      end
    end

    trait :with_expired_policy do
      after(:create) do |insured_entity|
        create(:policy, status: 'expired',
               start_date: 2.years.ago,
               end_date: 1.year.ago,
               insured_entity: insured_entity)
      end
    end

    trait :with_multiple_policies do
      after(:create) do |insured_entity|
        create(:policy, :active, insured_entity: insured_entity)
        create(:policy, status: 'expired',
               start_date: 2.years.ago,
               end_date: 1.year.ago,
               insured_entity: insured_entity)
      end
    end
  end
end
