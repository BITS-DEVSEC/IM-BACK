FactoryBot.define do
  factory :insurer do
    association :user
    name { Faker::Company.unique.name }
    description { Faker::Company.catch_phrase }
    contact_email { Faker::Internet.email }
    contact_phone { Faker::PhoneNumber.phone_number }

    after(:build) do |insurer|
      image_path = Rails.root.join('spec/fixtures/files/sample_image.jpg')
      file = Rack::Test::UploadedFile.new(image_path, 'image/jpeg')
      insurer.logo.attach(file)
    end

    trait :with_products do
      after(:create) do |insurer|
        create_list(:insurance_product, 3, insurer: insurer)
      end
    end
  end
end
