FactoryBot.define do
  factory :coverage_type do
    association :insurance_type
    sequence(:name) { |n| "Coverage Type #{n}" }
    description { Faker::Lorem.paragraph }

    trait :third_party do
      name { 'Third Party' }
      description { 'Third party liability coverage' }
    end
  end
end
