FactoryBot.define do
  factory :insurance_type do
    sequence(:name) { |n| "Insurance Type #{n}" }
    description { Faker::Lorem.paragraph }

    trait :motor do
      name { 'Motor' }
      description { 'Motor vehicle insurance' }
    end

    trait :health do
      name { 'Health' }
      description { 'Health insurance' }
    end
  end
end
