FactoryBot.define do
  factory :vehicle do
    sequence(:plate_number) { |n| "ABC#{n}" }
    sequence(:chassis_number) { |n| "CHASSIS#{n}" }
    sequence(:engine_number) { |n| "ENGINE#{n}" }
    year_of_manufacture { rand(2015..2024) }
    make { [ 'Toyota', 'Honda', 'Ford', 'BMW' ].sample }
    model { [ 'Corolla', 'Civic', 'Focus', '3 Series' ].sample }
    estimated_value { rand(500_000..2_000_000.0).round(2) }

    created_at { Time.now }
    updated_at { Time.now }

    after(:build) do |vehicle|
      image_path = Rails.root.join('spec/fixtures/files/sample_image.jpg')
      file = Rack::Test::UploadedFile.new(image_path, 'image/jpeg')

      vehicle.front_view_photo.attach(file)
      vehicle.back_view_photo.attach(file)
      vehicle.left_view_photo.attach(file)
      vehicle.right_view_photo.attach(file)
      vehicle.engine_photo.attach(file)
      vehicle.chassis_number_photo.attach(file)
      vehicle.libre_photo.attach(file)
    end


    trait :toyota do
      make { 'Toyota' }
      model { [ 'Corolla', 'Camry', 'RAV4', 'Highlander' ].sample }
    end

    trait :honda do
      make { 'Honda' }
      model { [ 'Civic', 'Accord', 'CR-V', 'Pilot' ].sample }
    end

    trait :ford do
      make { 'Ford' }
      model { [ 'Focus', 'Fusion', 'Escape', 'Explorer' ].sample }
    end

    trait :bmw do
      make { 'BMW' }
      model { [ '3 Series', '5 Series', 'X3', 'X5' ].sample }
    end

    trait :new_vehicle do
      year_of_manufacture { Date.current.year - 1 }
      created_at { Time.now }
    end

    trait :old_vehicle do
      year_of_manufacture { Date.current.year - 10 }
      created_at { Time.now - 5.days }
    end

    trait :very_old_vehicle do
      year_of_manufacture { Date.current.year - 20 }
    end

    trait :low_value do
      estimated_value { rand(100_000..500_000.0).round(2) }
    end

    trait :high_value do
      estimated_value { rand(2_000_000..5_000_000.0).round(2) }
    end

    trait :with_insured_entity do
      after(:create) do |vehicle|
        entity_type = EntityType.find_or_create_by(name: 'Vehicle') do |et|
          et.name = 'Vehicle'
        end
        create(:insured_entity, entity: vehicle, entity_type: entity_type)
      end
    end

    trait :with_entity_categories do
      transient do
        categories_count { 2 }
      end

      after(:create) do |vehicle, evaluator|
        entity_type = EntityType.find_by(name: 'Vehicle') || create(:entity_type, name: 'Vehicle')
        category_group = create(:category_group, name: 'Vehicle Type')

        evaluator.categories_count.times do
          category = create(:category, category_group: category_group)
          create(:entity_category, entity: vehicle, entity_type: entity_type, category: category)
        end
      end
    end

    trait :with_entity_attributes do
      transient do
        attributes_count { 3 }
      end

      after(:create) do |vehicle, evaluator|
        entity_type = EntityType.find_by(name: 'Vehicle') || create(:entity_type, name: 'Vehicle')

        evaluator.attributes_count.times do
          attribute_definition = create(:attribute_definition)
          create(:entity_attribute,
                entity: vehicle,
                entity_type: entity_type,
                attribute_definition: attribute_definition,
                value: "Value #{rand(1..100)}")
        end
      end
    end
  end
end
