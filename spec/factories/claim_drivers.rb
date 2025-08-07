FactoryBot.define do
  factory :claim_driver do
    association :claim
    name { Faker::Name.name }
    phone { "+2519#{rand(10000000..99999999)}" }
    license_number { Faker::Alphanumeric.alphanumeric(number: 10) }
    age { rand(25..70) }
    occupation { Faker::Job.title }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    subcity { Faker::Address.community }
    kebele { "Kebele #{rand(1..20)}" }
    house_number { rand(1..999).to_s }
    license_issuing_region { [ "Addis Ababa", "Oromia", "Amhara", "Tigray" ].sample }
    license_issue_date { 5.years.ago.to_date }
    license_expiry_date { 2.years.from_now.to_date }
    license_grade { [ "Grade 1", "Grade 2", "Grade 3" ].sample }

    trait :with_expired_license do
      license_issue_date { 3.years.ago.to_date }
      license_expiry_date { 1.year.ago.to_date }
    end

    trait :young_driver do
      age { rand(18..25) }
    end

    trait :experienced_driver do
      age { rand(35..60) }
      license_issue_date { rand(10..20).years.ago.to_date }
    end
  end
end
